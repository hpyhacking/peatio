# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Operations < Grape::API
        Operation::PLATFORM_TYPES.each do |op_type|
          desc "Creates new #{op_type} operation." do
            @settings[:scope] = :write_operations
            # success API::V2::Management::Entities::
          end
          params do
            requires :currency,
                     type: String,
                     values: -> { ::Currency.codes(bothcase: true) },
                     desc: 'The currency code.'
            requires :code,
                     type: Integer,
                     values: -> { ::Operations::Chart.codes },
                     desc: 'The Account code which this operation belongs to.'
            optional :debit,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation debit amount.'
            optional :credit,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation credit amount.'
            exactly_one_of :debit, :credit
          end
          post "/#{op_type.to_s.pluralize}/new" do
            klass = "operations/#{op_type}".camelize.constantize

          end
        end

        Operation::MEMBER_TYPES.each do |op_type|
          desc "Creates new #{op_type} operation." do
            @settings[:scope] = :write_operations
            # success API::V2::Management::Entities::
          end
          params do
            requires :currency,
                     type: String,
                     values: -> { ::Currency.codes(bothcase: true) },
                     desc: 'The currency code.'
            requires :code,
                     type: Integer,
                     values: -> { ::Operations::Chart.codes },
                     desc: 'The Account code which this operation belongs to.'
            requires :uid,
                     type: String,
                     desc: 'The shared user UID.'
            optional :debit,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation debit amount.'
            optional :credit,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation credit amount.'
            exactly_one_of :debit, :credit
          end
          post "/#{op_type.to_s.pluralize}/new" do

          end
        end
        #
        #  id             :integer          not null, primary key
        #  code           :integer          not null
        #  currency_id    :string(255)      not null
        #  reference_id   :integer
        #  reference_type :string(255)
        #  debit          :decimal(32, 16)  default(0.0), not null
        #  credit         :decimal(32, 16)  default(0.0), not null
        #  created_at     :datetime         not null
        #  updated_at     :datetime         not null
        #

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
