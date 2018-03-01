module ActiveModel
  module Translation
    alias :han :human_attribute_name
  end
end

ActiveRecord::Base.extend ActiveHash::Associations::ActiveRecordExtensions

module ActiveRecord
  class Base
    def self.inherited(child)
      super
      validates_lengths_from_database unless child == ActiveRecord::SchemaMigration
    end
  end
end
