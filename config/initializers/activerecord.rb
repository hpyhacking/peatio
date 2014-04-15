module ActiveModel
  module Translation
    alias :han :human_attribute_name
  end
end

ActiveRecord::Base.extend ActiveHash::Associations::ActiveRecordExtensions
