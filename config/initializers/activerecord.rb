# encoding: UTF-8
# frozen_string_literal: true

module ActiveRecord
  class Base
    def self.inherited(child)
      super
      validates_lengths_from_database unless child == ActiveRecord::SchemaMigration
    end
  end
end
