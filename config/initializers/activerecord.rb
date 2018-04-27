module ActiveRecord
  class Base
    def self.inherited(child)
      super
      validates_lengths_from_database unless child == ActiveRecord::SchemaMigration
    end
  end
end
