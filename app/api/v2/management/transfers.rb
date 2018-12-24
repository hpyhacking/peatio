# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Transfers < Grape::API
        # TODO: Add endpoints for listing Transfer/Transfers.

        desc 'Creates new transfer.' do
          @settings[:scope] = :write_transfers
        end
        params do
          requires :key,
                   type: Integer,
                   desc: 'Unique Transfer Key.'
          requires :kind,
                   type: String,
                   desc: 'Transfer Kind.'
          optional :desc,
                   type: String,
                   desc: 'Transfer Description.'

          requires(:operations, type: Array, allow_blank: false) do
            requires :currency,
                     type: String,
                     values: -> { Currency.codes(bothcase: true) },
                     desc: 'Operation currency.'
            requires :amount,
                     type: BigDecimal,
                     values: ->(v) { v.to_d.positive? },
                     desc: 'Operation amount.'

            requires :account_src, type: Hash do
              requires :code,
                       type: Integer,
                       values: -> { ::Operations::Account.pluck(:code) },
                       desc: 'Source Account code.'
              given code: ->(code) { ::Operations::Account.find_by(code: code).try(:scope).try(:member?) } do
                requires :uid,
                         type: String,
                         desc: 'Source Account User ID (for accounts with member scope).'
              end
            end

            requires :account_dst, type: Hash do
              requires :code,
                       type: Integer,
                       values: -> { ::Operations::Account.pluck(:code) },
                       desc: 'Destination Account code.'
              given code: ->(code) { ::Operations::Account.find_by(code: code).try(:scope).try(:member?) } do
                requires :uid,
                         type: String,
                         desc: 'Destination Account User ID (for accounts with member scope).'
              end
            end
          end
        end
        post '/transfers/new' do
          declared_params = declared(params)

          Transfer.transaction do
            transfer = Transfer.create!(declared_params.slice(:key, :kind, :desc))
            declared_params[:operations].map do |op_pair|
              shared_params = { currency: op_pair[:currency],
                                reference: transfer }

              debit_params = op_pair[:account_src]
                               .merge(debit: op_pair[:amount])
                               .merge(shared_params)
                               .compact


              credit_params = op_pair[:account_dst]
                               .merge(credit: op_pair[:amount])
                               .merge(shared_params)
                               .compact

              create_operation!(debit_params)
              create_operation!(credit_params)
            end
          end

          present Transfer.find_by!(key: declared_params[:key]),
                  with: Entities::Transfer
          status 200
        rescue ActiveRecord::RecordInvalid => e
          body errors: e.message
          status 422
        end
      end
    end
  end
end
