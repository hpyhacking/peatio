require 'peatio/i18n/backend/sqlite'

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

        def clear_original_yaml_files
          sqlite_backend = Peatio::I18n::Backend::Sqlite.new
          locales = sqlite_backend.available_locales
          files = locales.flat_map { |locale| Rails.root.join("config", "locales", "**", "#{locale}.yml") }
          Dir.glob(files).each do |f|
            File.delete f
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
