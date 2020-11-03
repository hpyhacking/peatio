# frozen_string_literal: true

module ActiveRecord
  class Base
    def self.inherited(child)
      super
      unless child == ActiveRecord::SchemaMigration
        validates_lengths_from_database
      end
    end
  end
end

Rails.configuration.database_support_json = \
  ActiveRecord::Base.configurations[Rails.env]['support_json']

Rails.configuration.database_adapter = \
  ActiveRecord::Base.configurations[Rails.env]['adapter']
