# frozen_string_literal: true

# InfluxDB test helpers
module InfluxTestHelper
  def delete_measurments(measurment)
    Peatio::InfluxDB.client.query("delete from #{measurment}")
  end
end

RSpec.configure { |config| config.include InfluxTestHelper }