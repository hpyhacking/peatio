module Jobs
  module Cron
    class CurrencyPrice
      PERIOD_TIME = 5
      class <<self
        def process
          Currency.coins.active.find_each do |currency|
            currency.blockchain_currencies.where(auto_update_fees_enabled: true).find_each do |b_currency|
              b_currency.update_fees
            end
          rescue StandardError => e
            report_exception_to_screen(e)
            next
          end
          sleep 60 * PERIOD_TIME
        end
      end
    end
  end
end
