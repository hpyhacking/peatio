# encoding: UTF-8
# frozen_string_literal: true

namespace :clear do
  desc 'Clear database from accounting information.'
  task accounting: :environment do
    table_names = %w[accounts adjustments assets beneficiaries deposits expenses
      liabilities orders payment_addresses revenues trades transfers triggers withdraws]
    table_names.each { |name| ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{name}") }
  end
end
