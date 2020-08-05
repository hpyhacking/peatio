# frozen_string_literal: true
require 'peatio/aml'

begin
  if ENV['AML_BACKEND'].present?
    require ENV['AML_BACKEND']
    Peatio::AML.adapter = "#{ENV.fetch('AML_BACKEND').capitalize}".constantize.new
  end
rescue StandardError, LoadError => e
  Rails.logger.error { e.message }
end
