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
                   type: String,
                   desc: 'Unique Transfer Key.'
          requires :category,
                   type: String,
                   desc: 'Transfer Category.'
          optional :description,
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

          attrs = declared_params.slice(:key, :category, :description)

          declared_params[:operations].each do |op_pair|
            currency = Currency.find(op_pair[:currency])

            debit_op = op_pair[:account_src].merge(debit: op_pair[:amount], credit: 0.0, currency: currency)
            credit_op = op_pair[:account_dst].merge(credit: op_pair[:amount], debit: 0.0, currency: currency)

            [debit_op, credit_op].each do |op|
              klass = ::Operations.klass_for(code: op['code'])

              uid = op.delete(:uid)
              op.merge!(member: Member.find_by!(uid: uid)) if uid.present?

              type = ::Operations::Account.find_by(code: op[:code]).type
              type_plural = type.pluralize
              if attrs[type_plural].present?
                attrs[type_plural].push(klass.new(op))
              else
                attrs[type_plural] = [klass.new(op)]
              end
            end
          end

          present Transfer.create!(attrs), with: Entities::Transfer
          status 201
        rescue ActiveRecord::RecordInvalid => e
          body errors: e.message
          status 422
        rescue ::Account::AccountError => e
          body errors: "Account balance is insufficient (#{e.message})"
          status 422
        end
      end
    end
  end
end
