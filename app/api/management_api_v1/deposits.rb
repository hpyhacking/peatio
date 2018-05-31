# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Deposits < Grape::API

    desc 'Returns deposits as paginated collection.' do
      @settings[:scope] = :read_deposits
      success ManagementAPIv1::Entities::Deposit
    end
    params do
      optional :uid,      type: String,  desc: 'The shared user ID.'
      optional :currency, type: String,  values: -> { Currency.codes(bothcase: true) }, desc: 'The currency code.'
      optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'The page number (defaults to 1).'
      optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'The number of deposits per page (defaults to 100, maximum is 1000).'
      optional :state,    type: String, values: -> { Deposit::STATES.map(&:to_s) }, desc: 'The state to filter by.'
    end
    post '/deposits' do
      currency = Currency.find(params[:currency]) if params[:currency].present?
      member   = Authentication.find_by!(provider: :barong, uid: params[:uid]).member if params[:uid].present?

      Deposit
        .order(id: :desc)
        .tap { |q| q.where!(currency: currency) if currency }
        .tap { |q| q.where!(member: member) if member }
        .tap { |q| q.where!(aasm_state: params[:state]) if params[:state] }
        .includes(:member)
        .includes(:currency)
        .page(params[:page])
        .per(params[:limit])
        .tap { |q| present q, with: ManagementAPIv1::Entities::Deposit }
      status 200
    end

    desc 'Returns deposit by TID.' do
      @settings[:scope] = :read_deposits
      success ManagementAPIv1::Entities::Deposit
    end
    params do
      requires :tid, type: String, desc: 'The transaction ID.'
    end
    post '/deposits/get' do
      present Deposit.find_by!(params.slice(:tid)), with: ManagementAPIv1::Entities::Deposit
    end

    desc 'Creates new fiat deposit with state set to «submitted». ' \
         'Optionally pass field «state» set to «accepted» if want to load money instantly. ' \
         'You can also use PUT /fiat_deposits/:id later to load money or cancel deposit.' do
      @settings[:scope] = :write_deposits
      success ManagementAPIv1::Entities::Deposit
    end
    params do
      requires :uid,      type: String, desc: 'The shared user ID.'
      optional :tid,      type: String, desc: 'The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied.'
      requires :currency, type: String, values: -> { Currency.fiats.codes(bothcase: true) }, desc: 'The currency code.'
      requires :amount,   type: BigDecimal, desc: 'The deposit amount.'
      optional :state,    type: String, desc: 'The state of deposit.', values: %w[accepted]
    end
    post '/deposits/new' do
      member   = Authentication.find_by(provider: :barong, uid: params[:uid])&.member
      currency = Currency.find(params[:currency])
      data     = { member: member, currency: currency }.merge!(params.slice(:amount, :tid))
      deposit  = ::Deposits::Fiat.new(data)
      if deposit.save
        deposit.charge! if params[:state] == 'accepted'
        present deposit, with: ManagementAPIv1::Entities::Deposit
      else
        body errors: deposit.errors.full_messages
        status 422
      end
    end

    desc 'Allows to load money or cancel deposit.' do
      @settings[:scope] = :write_deposits
      success ManagementAPIv1::Entities::Deposit
    end
    params do
      requires :tid,   type: String, desc: 'The shared transaction ID.'
      requires :state, type: String, desc: 'The new state to apply.', values: %w[canceled accepted]
    end
    put '/deposits/state' do
      deposit = ::Deposits::Fiat.find_by!(params.slice(:tid))
      if deposit.submitted?
        deposit.with_lock do
          params[:state] == 'canceled' ? deposit.cancel! : deposit.accept!
        end
        present deposit, with: ManagementAPIv1::Entities::Deposit
        status 200
      else
        status 422
      end
    end
  end
end
