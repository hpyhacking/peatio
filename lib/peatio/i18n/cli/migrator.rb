require 'peatio/i18n/Backend/Sqlite'

module Peatio
  module I18n
    module CLI
      # Migrate data from Simple backend (yml) to Sqlite
      class Migrator

        module HashDeepTraverse
          def deep_traverse_hash(hash, &block)
            stack = hash.map { |k,v| [[k], v] }
            while !stack.empty?
              key, value = stack.pop
              yield(key, value)
              if value.is_a? Hash
                value.each{ |k, v| stack.push [key.dup << k, v] }
              end
            end
          end
        end

        include HashDeepTraverse

        def migrate
          fail "Table translations in i18n.db is not empty!" if table_populated?

          store(*load_simple_translations)
        end

        private
        def table_populated?
          !Peatio::I18n::Models::Translation.count.zero?
        end

        def store(locales, translations)
          puts "Found available locales from Simple Backend:"
          puts locales.join(", ")
          puts

          sqlite_backend  = Peatio::I18n::Backend::Sqlite.new
          storing_locales = sqlite_backend.available_locales
          @key_separator  = sqlite_backend.default_separator

          puts "Storing these locales to Sqlite Backend:"
          puts storing_locales.join(", ")
          puts

          storing_locales.each do |l|
            store_locale(l, translations[l.to_sym])
            puts "Stored #{l}"
          end
        end

        def load_simple_translations
          simple_backend = ::I18n::Backend::Simple.new
          [simple_backend.available_locales, simple_backend.send(:translations)]
        end

        def store_locale(locale, translations)
          deep_traverse_hash(translations) do |path, value|
            # TODO: what about other types, e.g. Array?
            if String === value
              key = path.join(key_separator)
              record = Peatio::I18n::Models::Translation.find_or_create_by(key: key)
              record.update_column locale, value
            end
          end
        end

        def key_separator
          @key_separator ||= "."
        end
      end
    end
  end
end
