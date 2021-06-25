module Jobs
  module Cron
    class AdjustNetworkFee
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

          sleep Peatio::App.config.adjust_network_fee_fetch_period_time
        end
      end
    end
  end
end
