# encoding: UTF-8
# frozen_string_literal: true

module Operations
  class Chart
    # TODO: Read chart from yml.
    CHART = [
      { code:           101,
        type:           :asset,
        kind:           :main,
        currency_type:  :fiat,
        description:    'Main Fiat Assets Account',
        scope:          %i[member]
      },
      { code:           102,
        type:           :asset,
        kind:           :main,
        currency_type:  :coin,
        description:    'Main Crypto Assets Account',
        scope:          %i[member]
      },
      { code:           201,
        type:           :liability,
        kind:           :main,
        currency_type:  :fiat,
        description:    'Main Fiat Liabilities Account',
        scope:          %i[member]
      },
      { code:           202,
        type:           :liability,
        kind:           :main,
        currency_type:  :coin,
        description:    'Main Crypto Liabilities Account',
        scope:          %i[member]
      },
      { code:           211,
        type:           :liability,
        kind:           :locked,
        currency_type:  :fiat,
        description:    'Locked Fiat Liabilities Account',
        scope:          %i[member]
      },
      { code:           212,
        type:           :liability,
        kind:           :locked,
        currency_type:  :coin,
        description:    'Locked Crypto Liabilities Account',
        scope:          %i[member]
      },
      { code:           301,
        type:           :revenue,
        kind:           :main,
        currency_type:  :fiat,
        description:    'Main Fiat Revenues Account',
        scope:          %i[platform]
      },
      { code:           302,
        type:           :revenue,
        kind:           :main,
        currency_type:  :coin,
        description:    'Main Crypto Revenues Account',
        scope:          %i[platform]
      },
      { code:           401,
        type:           :expense,
        kind:           :main,
        currency_type:  :fiat,
        description:    'Main Fiat Expenses Account',
        scope:          %i[platform]
      },
      { code:           402,
        type:           :expense,
        kind:           :main,
        currency_type:  :coin,
        description:    'Main Crypto Expenses Account',
        scope:          %i[platform]
      }
    ].map(&:with_indifferent_access).freeze

    class << self
      def code_for(options)
        # We use #as_json to stringify hash values.
        # {type: 'asset'}.as_json == {type: :asset}.as_json #=> true
        CHART
          .find { |entry| entry.merge(options).as_json == entry.as_json }
          .tap do |entry|
            if entry.blank?
              raise StandardError, "Account for #{options} doesn't exists."\
            end
          end
          .fetch(:code)
      end

      def find_chart(code)
        CHART.find { |entry| entry.fetch(:code) == code }
      end

      def codes
        CHART.map { |entry| entry.fetch(:code) }
      end
    end
  end
end
