# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Helpers
        def create_operation!(attrs)
          account = ::Operations::Account.find_by(code: attrs.fetch(:code))
          if account.scope.member?
            create_member_operation!(attrs)
          else
            create_platform_operation!(attrs)
          end
        end

        def set_ets_context!
          Raven.tags_context(
            peatio_version: Peatio::Application::VERSION
          ) if defined?(Raven)
        end

        private

        def create_platform_operation!(attrs)
          currency = Currency.find(attrs.fetch(:currency))
          klass = ::Operations::Account
                    .find_by(code: attrs.fetch(:code))
                    .type
                    .yield_self { |type| "operations/#{type}" }
                    .camelize
                    .constantize

          if klass == ::Operations::Revenue && attrs.dig(:uid)
            member_id = Member.find_by!(uid: attrs.fetch(:uid)).id
          else
            member_id = nil
          end

          if attrs[:credit].present?
            klass.credit!({
              amount: attrs.fetch(:credit),
              currency: currency,
              code: attrs.fetch(:code),
              member_id: member_id,
              reference: attrs[:reference]
            }.compact)
          elsif attrs[:debit].present?
            klass.debit!({
              amount: attrs.fetch(:debit),
              currency: currency,
              code: attrs.fetch(:code),
              member_id: member_id,
              reference: attrs[:reference]
            }.compact)
          end
        end

        def create_member_operation!(attrs)
          member = Member.find_by!(uid: attrs.fetch(:uid))
          currency = Currency.find(attrs.fetch(:currency))
          klass = ::Operations::Account
                    .find_by(code: attrs.fetch(:code))
                    .type
                    .yield_self { |type| "operations/#{type}" }
                    .camelize
                    .constantize

          if attrs[:credit].present?
            amount = attrs.fetch(:credit)

            ActiveRecord::Base.transaction do
              op = klass.credit!(amount: amount,
                                 currency: currency,
                                 code: attrs.fetch(:code),
                                 member_id: member.id,
                                 reference: attrs[:reference])

              credit_legacy_balance!(amount: amount,
                                     member: member,
                                     currency: currency,
                                     account: op.account)
              op
            end
          elsif attrs[:debit].present?
            amount = attrs.fetch(:debit)

            ActiveRecord::Base.transaction do
              op = klass.debit!(amount: amount,
                                currency: currency,
                                code: attrs.fetch(:code),
                                member_id: member.id,
                                reference: attrs[:reference])

              debit_legacy_balance!(amount: amount,
                                    member: member,
                                    currency: currency,
                                    account: op.account)
              op
            end
          end
        end

        # @deprecated
        def credit_legacy_balance!(amount:, member:, currency:, account:)
          if account.kind.main?
            member.get_account(currency).plus_funds(amount)
          elsif account.kind.locked?
            member.get_account(currency).plus_funds(amount)
            member.get_account(currency).lock_funds(amount)
          end
        end

        # @deprecated
        def debit_legacy_balance!(amount:, member:, currency:, account:)
          if account.kind.main?
            member.get_account(currency).sub_funds(amount)
          elsif account.kind.locked?
            member.get_account(currency).unlock_and_sub_funds(amount)
          end
        end
      end
    end
  end
end
