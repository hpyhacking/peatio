module Datagrid
  module Naming
    extend ActiveSupport::Concern
    extend ::ActiveModel::Naming

    module ClassMethods
      def grid_name
        I18n.t("activerecord.models.#{model_name.i18n_key}")
      end
    end
  end
end

