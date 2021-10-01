# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Deposits < Grape::API

        desc 'Returns deposits as paginated collection.' do
          @settings[:scope] = :read_deposits
          success API::V2::Management::Entities::Deposit
        end
        params do
          optional :uid, type: String,  desc: 'The shared user ID.'
          optional :from_id, type: Integer,  desc: 'Unique blockchain identifier in database. Will return starting from given id.'
          optional :currency, type: String,  values: -> { Currency.codes(bothcase: true) }, desc: 'The currency code.'
          optional :blockchain_key, type: String, values: -> { ::Blockchain.pluck(:key) }, desc: 'Blockchain key of the requested deposit'
          optional :page, type: Integer, default: 1, integer_gt_zero: true, desc: 'The page number (defaults to 1).'
          optional :limit, type: Integer, default: 100, range: 1..1000, desc: 'The number of deposits per page (defaults to 100, maximum is 1000).'
          optional :state, type: String, values: -> { ::Deposit.aasm.states.map(&:name).map(&:to_s) }, desc: 'The state to filter by.'
        end
        post '/deposits' do
          currency = Currency.find(params[:currency]) if params[:currency].present?
          member   = Member.find_by!(uid: params[:uid]) if params[:uid].present?
          Deposit
            .order(id: :desc)
            .tap { |q| q.where!(currency: currency) if currency }
            .tap { |q| q.where!(member: member) if member }
            .tap { |q| q.where!(aasm_state: params[:state]) if params[:state] }
            .tap { |q| q.where!('id > ?', params[:from_id]) if params[:from_id] }
            .tap { |q| q.where!(blockchain_key: params[:blockchain_key]) if params[:blockchain_key] }
            .includes(:member, :currency)
            .page(params[:page])
            .per(params[:limit])
            .tap { |q| present q, with: API::V2::Management::Entities::Deposit }
          status 200
        end

        desc 'Returns deposit by TID.' do
          @settings[:scope] = :read_deposits
          success API::V2::Management::Entities::Deposit
        end
        params do
          requires :tid, type: String, desc: 'The transaction ID.'
        end
        post '/deposits/get' do
          present Deposit.find_by!(params.slice(:tid)), with: API::V2::Management::Entities::Deposit
        end

        desc 'Creates new fiat deposit with state set to «submitted». ' \
            'Optionally pass field «state» set to «accepted» if want to load money instantly. ' \
            'You can also use PUT /fiat_deposits/:id later to load money or cancel deposit.' do
          @settings[:scope] = :write_deposits
          success API::V2::Management::Entities::Deposit
        end
        params do
          requires :uid,      type: String, desc: 'The shared user ID.'
          optional :tid,      type: String, desc: 'The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied.'
          requires :currency, type: String, values: -> { Currency.fiats.codes(bothcase: true) }, desc: 'The currency code.'
          requires :amount,   type: BigDecimal, desc: 'The deposit amount.'
          requires :blockchain_key, type: String, desc: 'The blockchain key.', values: -> { ::Blockchain.pluck(:key) }
          optional :state,    type: String, desc: 'The state of deposit.', values: %w[accepted]
          optional :transfer_type,  type: String,
                                    values:  { value: -> { Deposit::TRANSFER_TYPES.keys }, message: 'account.deposit.transfer_type_not_in_list' },
                                    desc: -> { API::V2::Admin::Entities::Deposit.documentation[:transfer_type][:desc] }
        end
        post '/deposits/new' do
          member   = Member.find_by(uid: params[:uid])
          currency = Currency.find(params[:currency])
          blockchain_currency = BlockchainCurrency.find_by!(currency_id: currency.id, blockchain_key: params[:blockchain_key])

          unless blockchain_currency.deposit_enabled?
            error!({ errors: ['management.currency.deposit_disabled'] }, 422)
          end

          data     = { member: member, currency: currency, blockchain_key: params[:blockchain_key] }.merge!(params.slice(:amount, :tid, :transfer_type))
          deposit  = ::Deposits::Fiat.new(data)
          if deposit.save
            deposit.charge! if params[:state] == 'accepted'
            present deposit, with: API::V2::Management::Entities::Deposit
          else
            body errors: deposit.errors.full_messages
            status 422
          end
        end

        desc 'Allows to load money or cancel deposit.' do
          @settings[:scope] = :write_deposits
          success API::V2::Management::Entities::Deposit
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
            present deposit, with: API::V2::Management::Entities::Deposit
            status 200
          else
            status 422
          end
        end
      end
    end
  end
end
