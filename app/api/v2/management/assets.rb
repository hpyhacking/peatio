# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Assets < Grape::API

        desc 'Creates new asset operation.' do
          @settings[:scope] = :write_operations
          success API::V2::Management::Entities
        end
        params do

        end
        post '/assets'

        # desc 'Creates new fiat deposit with state set to «submitted». ' \
        #     'Optionally pass field «state» set to «accepted» if want to load money instantly. ' \
        #     'You can also use PUT /fiat_deposits/:id later to load money or cancel deposit.' do
        #   @settings[:scope] = :write_deposits
        #   success API::V2::Management::Entities::Deposit
        # end
        # params do
        #   requires :uid,      type: String, desc: 'The shared user ID.'
        #   optional :tid,      type: String, desc: 'The shared transaction ID. Must not exceed 64 characters. Peatio will generate one automatically unless supplied.'
        #   requires :currency, type: String, values: -> { Currency.fiats.codes(bothcase: true) }, desc: 'The currency code.'
        #   requires :amount,   type: BigDecimal, desc: 'The deposit amount.'
        #   optional :state,    type: String, desc: 'The state of deposit.', values: %w[accepted]
        # end
        # post '/deposits/new' do
        #   member   = Member.find_by(uid: params[:uid])
        #   currency = Currency.find(params[:currency])
        #   data     = { member: member, currency: currency }.merge!(params.slice(:amount, :tid))
        #   deposit  = ::Deposits::Fiat.new(data)
        #   if deposit.save
        #     deposit.charge! if params[:state] == 'accepted'
        #     present deposit, with: API::V2::Management::Entities::Deposit
        #   else
        #     body errors: deposit.errors.full_messages
        #     status 422
        #   end
        # end
      end
    end
  end
end
