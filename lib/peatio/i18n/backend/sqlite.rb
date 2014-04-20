require 'peatio/i18n/models/translation'

module Peatio
  module I18n
    module Backend
      class Sqlite
        include ::I18n::Backend::Base

        def available_locales
          Models::Translation.column_names - %w(key desc)
        end

        def reload!
          super
        end

        def translate(locale, key, options = {})
          super
        end

        def default_separator
          "."
        end

        protected

          def lookup(locale, key, scope = [], options = {})
            if record = Models::Translation.find_by(key: key)
              value_from_record(record, locale)
            elsif children = Models::Translation.where(["key like ?", "#{key}#{default_separator}%"])
              hashify_records(key, children.to_a, locale)
            end
          end

          def hashify_records(root_key, children, locale)
            return nil if children.empty?

            hash = children.inject({}) do |result, child|
              key = child.key.gsub(Regexp.new("^" + Regexp.escape("#{root_key}#{default_separator}")), "")

              if key.index(default_separator)
                next_root = key.slice(0, key.index(default_separator))
                next_root_key = root_key + default_separator + next_root
                result[next_root.to_sym] = hashify_records(
                  next_root_key,
                  children.select { |r| r.key.starts_with? next_root_key },
                  locale
                )
              else
                result[key.to_sym] = value_from_record(child, locale)
              end

              result
            end

            hash
          end

          def value_from_record(record, locale)
            value = record.send(locale) rescue ""
            value.presence || record.en # fall back to :en
          end
      end
    end
  end
end
