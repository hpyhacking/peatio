module ActiveModel
  module Dirty
    def changes_attributes
      HashWithIndifferentAccess[changed.map { |attr| [attr, __send__(attr)] }]
    end

    def changes_attributes_as_json
      ca, json = changes_attributes, self.as_json
      json.each do |key, value|
        ca[key.to_s] = value if ca.key?(key)
      end
      ca
    end
  end
end

