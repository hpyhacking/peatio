# encoding: UTF-8
# frozen_string_literal: true

module Enumerize
  class Attribute
    def value_options(options = {})
      values = if options.empty?
        @values
      else
        raise ArgumentError, 'Options cannot have both :only and :except' if options[:only] && options[:except]

        only = Array(options[:only]).map(&:to_s)
        except = Array(options[:except]).map(&:to_s)

        @values.reject do |value|
          if options[:only]
            !only.include?(value)
          elsif options[:except]
            except.include?(value)
          end
        end
      end
      values.map { |v| [v.text, v.value] }
    end
  end
end
