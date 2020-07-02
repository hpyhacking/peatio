# frozen_string_literal: true

require 'csv'

namespace :distribution do
  # Detailed instruction https://github.com/rubykube/peatio/blob/master/docs/tasks/distribution.md
  # Required fields for distribution:
  # - uid
  # - currency_id
  # - amount
  #
  # Usage:
  # For distribution process: -> bundle exec rake distribution:process['file_name.csv']

  desc 'Distribution process'
  task :process, [:config_load_path] => [:environment] do |_, args|
    csv_table = File.read(Rails.root.join(args[:config_load_path]))
    count = 0
    errors_count = 0
    CSV.parse(csv_table, headers: true, quote_empty: false).each do |row|
      row = row.to_h.compact.symbolize_keys!
      uid = row[:uid]
      currency_id = row[:currency_id]
      amount = row[:amount].to_d
      member = Member.find_by_uid!(uid)
      currency = Currency.find(currency_id)
      account = member.get_account(currency)

      ActiveRecord::Base.transaction do
        Operations::Asset.credit!(currency: currency, amount: amount, reference_type: 'Distribution')
        Operations::Liability.credit!(kind: :main, currency: currency, member_id: member.id, amount: amount, reference_type: 'Distribution')
        account.update!(balance: account.balance + amount)
      end
    rescue StandardError => e
      message = { error: e.message, uid: row[:uid] }
      Rails.logger.error message
      errors_count += 1
    end
    Kernel.puts "Distributions processed #{count}"
    Kernel.puts "Errored #{errors_count}"
  end
end
