# frozen_string_literal: true

namespace :fetch do
  desc 'Fetch currency price'
  task :price, %i[quote external_currencies_service] => [:environment] do |_, args|
    # TODO
    # Add ability to take price from platform market
    Currency.find_in_batches(batch_size: 50) do |group|
      group.each do |record|
        url = args.external_currencies_service || ENV['EXTERNAL_CURRENCIES_SERVICE']
        raise 'There is no external currencies service configured' unless url.present?

        # API call to external currencies service to get current currency price
        response = Faraday.get(url, { code: record.code, quote: args.quote })
        response_body = JSON.parse(response.body)

        next unless response_body['current_price'].present?

        Rails.logger.info { "Updating currency #{record.code} with price #{response_body["current_price"]}" }
        record.update!(price: response_body['current_price'])
      rescue Faraday::Error, StandardError  => e
        Rails.logger.error e.inspect
      end
    end
  end
end
