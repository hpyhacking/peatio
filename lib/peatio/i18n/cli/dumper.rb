require 'peatio/i18n/Backend/Sqlite'

module Peatio
  module I18n
    module CLI
      # Dump data from Sqlite Backend to yml for Simple Backend
      class Dumper
        def dump
          prepare_directory

          sqlite_backend = Peatio::I18n::Backend::Sqlite.new
          translations = sqlite_backend.translations
          sqlite_backend.available_locales.each do |locale|
            File.open(locales_directory.join(locale + ".yml"), "w") do |yml|
              yml << translations.extract!(locale).to_yaml
              puts "Dumped #{yml.path}"
            end
          end
        end

        private
        def locales_directory
          Rails.root.join("config", "locales", "compiled")
        end

        def prepare_directory
          Dir.mkdir locales_directory unless File.exist?(locales_directory)
        end
      end
    end
  end
end
