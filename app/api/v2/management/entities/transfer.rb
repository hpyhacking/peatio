# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Entities
        class Transfer < Base
          expose :key,
                 documentation: {
                   type: String,
                   desc: 'Unique Transfer Key.'
                 }

          expose :category,
                 documentation: {
                   type: String,
                   desc: 'Transfer Category.'
                 }

          expose :description,
                 documentation: {
                   type: String,
                   desc: 'Transfer Description'
                 }

          # Expose assets, expenses, liabilities, revenues if present.
          ::Operations::Account::TYPES.map(&:pluralize).each do |op_t|
            expose op_t,
                   using: Operation,
                   if: ->(transfer) { transfer.public_send(op_t).present? },
                   documentation: {
                     desc: "Transfer #{op_t}"
                   }
          end
        end
      end
    end
  end
end
