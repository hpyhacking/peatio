# encoding: UTF-8
# frozen_string_literal: true

require 'securerandom'

class Member < ApplicationRecord
  has_many :orders
  has_many :accounts
  has_many :stats_member_pnl
  has_many :payment_addresses
  has_many :withdraws, -> { order(id: :desc) }
  has_many :deposits, -> { order(id: :desc) }
  has_many :beneficiaries, -> { order(id: :desc) }

  scope :enabled, -> { where(state: 'active') }

  before_validation :downcase_email

  validates :uid, length: { maximum: 32 }
  validates :email, allow_blank: true, uniqueness: true, email: true
  validates :level, numericality: { greater_than_or_equal_to: 0 }
  validates :role, inclusion: { in: ::Ability.roles }

  before_create do
    self.group = group.strip.downcase
    self.beneficiaries_whitelisting = Peatio::App.config.force_beneficiaries_whitelisting
  end

  class << self
    def groups
      TradingFee.distinct.pluck(:group)
    end
  end

  def trades
    Trade.where('maker_id = ? OR taker_id = ?', id, id)
  end

  def role
    super&.inquiry
  end

  def admin?
    role == "admin"
  end

  def get_account(model_or_id_or_code)
    if model_or_id_or_code.is_a?(String) || model_or_id_or_code.is_a?(Symbol)
      accounts.find_or_create_by(currency_id: model_or_id_or_code, type: ::Account::DEFAULT_TYPE)
    elsif model_or_id_or_code.is_a?(Currency)
      accounts.find_or_create_by(currency: model_or_id_or_code, type: ::Account::DEFAULT_TYPE)
    end
  # Thread Safe Account creation
  rescue ActiveRecord::RecordNotUnique
    if model_or_id_or_code.is_a?(String) || model_or_id_or_code.is_a?(Symbol)
      accounts.find_by(currency_id: model_or_id_or_code, type: ::Account::DEFAULT_TYPE)
    elsif model_or_id_or_code.is_a?(Currency)
      accounts.find_by(currency: model_or_id_or_code, type: ::Account::DEFAULT_TYPE)
    end
  end

  # @deprecated
  def touch_accounts
    Currency.find_each do |currency|
      next if accounts.where(currency: currency).exists?
      accounts.create!(currency: currency)
    end
  end

  def balance_for(currency:, kind:)
    account_code = Operations::Account.find_by(
      type: :liability,
      kind: kind,
      currency_type: currency.type
    ).code
    liabilities = Operations::Liability.where(member_id: id, currency: currency, code: account_code)
    liabilities.sum('credit - debit')
  end

  def legacy_balance_for(currency:, kind:)
    if kind.to_sym == :main
      get_account(currency).balance
    elsif kind.to_sym == :locked
      get_account(currency).locked
    else
      raise Operations::Exception, "Account for #{options} doesn't exists."
    end
  end

  def revert_trading_activity!(trades)
    trades.each(&:revert_trade!)
  end

  def payment_address(wallet_id, remote = false)
    wallet = Wallet.find(wallet_id)

    return if wallet.blank?

    pa = PaymentAddress.find_by(member: self, wallet: wallet, remote: remote)

    if pa.blank?
      pa = payment_addresses.create!(wallet: wallet)
    elsif pa.address.blank?
      pa.enqueue_address_generation
    end

    pa
  end

  # Attempts to create additional deposit address for account.
  def payment_address!(wallet_id, remote = false)
    wallet = Wallet.find(wallet_id)

    return if wallet.blank?

    pa = PaymentAddress.find_by(member: self, wallet: wallet)

    # The address generation process is in progress.
    if pa.present? && pa.address.blank?
      pa
    else
      # allows user to have multiple addresses
      pa = payment_addresses.create!(wallet: wallet, remote: remote)
    end
    pa
  end

  private

  def downcase_email
    self.email = email.try(:downcase)
  end

  class << self
    def uid(member_id)
      Member.find_by(id: member_id)&.uid
    end

    def find_by_username_or_uid(uid_or_username)
      if Member.find_by(uid: uid_or_username).present?
        Member.find_by(uid: uid_or_username)
      elsif Member.find_by(username: uid_or_username).present?
        Member.find_by(username: uid_or_username)
      end
    end

    # Create Member object from payload
    # == Example payload
    # {
    #   :iss=>"barong",
    #   :sub=>"session",
    #   :aud=>["peatio"],
    #   :email=>"admin@barong.io",
    #   :username=>"barong",
    #   :uid=>"U123456789",
    #   :role=>"admin",
    #   :state=>"active",
    #   :level=>"3",
    #   :iat=>1540824073,
    #   :exp=>1540824078,
    #   :jti=>"4f3226e554fa513a"
    # }

    def from_payload(p)
      params = filter_payload(p)
      validate_payload(params)
      member = Member.find_or_create_by(uid: p[:uid]) do |m|
        m.email = params[:email]
        m.username = params[:username]
        m.role = params[:role]
        m.state = params[:state]
        m.level = params[:level]
      end
      member.assign_attributes(params)
      member.beneficiaries_whitelisting = true if Peatio::App.config.force_beneficiaries_whitelisting
      member.save! if member.changed?
      member
    end

    # Filter and validate payload params
    def filter_payload(payload)
      payload.slice(:email, :username, :uid, :role, :state, :level)
    end

    def validate_payload(p)
      fetch_email(p)
      p.fetch(:uid).tap { |uid| raise(Peatio::Auth::Error, 'UID is blank.') if uid.blank? }
      p.fetch(:role).tap { |role| raise(Peatio::Auth::Error, 'Role is blank.') if role.blank? }
      p.fetch(:level).tap { |level| raise(Peatio::Auth::Error, 'Level is blank.') if level.blank? }
      p.fetch(:state).tap do |state|
        raise(Peatio::Auth::Error, 'State is blank.') if state.blank?
        raise(Peatio::Auth::Error, 'State is not active.') unless state == 'active'
      end
    end

    def fetch_email(payload)
      payload[:email].to_s.tap do |email|
        if email.present?
         raise(Peatio::Auth::Error, 'E-Mail is invalid.') unless EmailValidator.valid?(email)
        end
      end
    end

    def search(field: nil, term: nil)
      term = "%#{term}%"
      case field
      when 'email'
        where("email LIKE ?", term)
      when 'uid'
        where('uid LIKE ?', term)
      when 'wallet_address'
        joins(:payment_addresses).where('payment_addresses.address LIKE ?', term)
      else
        all
      end.order(:id).reverse_order
    end
  end
end

# == Schema Information
# Schema version: 20210909120210
#
# Table name: members
#
#  id         :bigint           not null, primary key
#  uid        :string(32)       not null
#  email      :string(255)
#  level      :integer          not null
#  role       :string(16)       not null
#  group      :string(32)       default("vip-0"), not null
#  state      :string(16)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  username   :string(255)
#
# Indexes
#
#  index_members_on_email     (email) UNIQUE
#  index_members_on_uid       (uid) UNIQUE
#  index_members_on_username  (username) UNIQUE
#
