# encoding: UTF-8
# frozen_string_literal: true

class PrecisionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless options.key?(:less_than_or_eq_to) && value.present?

    precision = if options[:less_than_or_eq_to].respond_to?(:call)
                  options[:less_than_or_eq_to].call(record)
                else
                  options[:less_than_or_eq_to]
                end

    unless value.is_a?(Numeric)
      record.errors.add(attribute, 'must be a number')
      return
    end

    unless value.round(precision) == value
      record.errors.add(attribute, "precision must be less than or equal to #{precision}")
    end
  end
end
