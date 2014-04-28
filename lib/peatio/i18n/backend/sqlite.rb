require 'peatio/i18n/models/translation'

module Peatio
  module I18n
    module Backend
      class Sqlite

        module PathToHash
          # https://gist.github.com/potatosalad/760726
          def new_hash(*args)
            leet = lambda { |hsh, key| hsh[key] = Hash.new(&leet) }
            Hash.new(*args, &leet)
          end

          def explode_hash(hash, divider = '.')
            h = new_hash
            def h.recursive_send(*args)
              args.inject(self) { |obj, m| obj.send(m.shift, *m) }
            end

            hash.dup.each do |k, v|
              tree = k.split(divider).map { |x| [:[], x] }
              tree.push([:[]=, tree.pop[1], v])
              h.recursive_send(*tree)
            end
            h
          end
        end

        include ::I18n::Backend::Base, PathToHash

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
