require 'peatio/i18n/models/translation'

module Peatio
  module I18n
    module Backend
      class Sqlite

        module KeyPathToHash
          # https://gist.github.com/potatosalad/760726
          def new_hash(*args)
            leet = lambda { |hsh, key| hsh[key] = Hash.new(&leet) }
            Hash.new(*args, &leet)
          end

          def set_key_path(hash, key_path, value)
            key = key_path.shift
            if key_path.empty?
              hash[key] = value
            else
              set_key_path hash[key], key_path, value
            end
          end

          # Transform a hash with KeyPath form keys to normal hash"
          #
          #     explode_hash({
          #       'tags.vip'  => 'VIP',
          #       'tags.hero' => 'Hero Member'
          #     }
          #
          # would return
          #     {
          #       'tags' => { 'vip' => 'VIP', 'hero' => 'Hero member' }
          #     }
          #
          def explode_hash(hash, divider = '.')
            h = new_hash
            hash.each { |k, v| set_key_path h, k.split(divider), v }
            h
          end
        end

        include ::I18n::Backend::Base, KeyPathToHash

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

        def translations
          locales = available_locales

          hash_with_path = Models::Translation.all.inject({}) do |hash, record|
            locales.each do |locale|
              hash["#{locale}#{default_separator}#{record.key}"] = record.send(locale)
            end
            hash
          end

          explode_hash(hash_with_path, default_separator)
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
