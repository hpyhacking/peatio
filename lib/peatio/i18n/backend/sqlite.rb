require 'peatio/i18n/models/translation'

module Peatio
  module I18n
    module Backend
      class Sqlite
        include ::I18n::Backend::Base

        def available_locales
          Peatio::I18n::Models::Translation.column_names - %w(key desc)
        end

        def reload!
          super
        end

        def translate(locale, key, options = {})
          super
        end

        protected

          def lookup(locale, key, scope = [], options = {})
            nil
          end
      end
    end
  end
end
