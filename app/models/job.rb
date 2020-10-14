# frozen_string_literal: true

class Job < ApplicationRecord

  serialize :data, JSON unless Rails.configuration.database_support_json

  before_create { self.finished_at = Time.now }

  def self.execute(name)
    job = new(name: name, started_at: Time.now)
    result = yield.symbolize_keys
    job.update!(pointer: result[:pointer], counter: result[:counter], error_code: 0)
  rescue StandardError => e
    job.error_code = 1
    job.error_message = e.message
    job.save!
  end
end

# == Schema Information
# Schema version: 20200827105929
#
# Table name: jobs
#
#  id            :bigint           not null, primary key
#  name          :string(255)      not null
#  pointer       :integer          unsigned
#  counter       :integer
#  data          :json
#  error_code    :integer          default(255), unsigned, not null
#  error_message :string(255)
#  started_at    :datetime
#  finished_at   :datetime
#
