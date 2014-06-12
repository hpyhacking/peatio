module Peatio
  module I18n
    module Models
      class Base < ActiveRecord::Base
        self.abstract_class = true
        establish_connection(
          adapter:  "sqlite3",
          database: Rails.root.join("config", "locales", "i18n.db")
        )
      end
    end
  end
end
