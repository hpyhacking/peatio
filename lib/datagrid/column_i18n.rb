module Datagrid
  module ColumnI18n
    extend ActiveSupport::Concern

    module ClassMethods
      def column_localtime(name, options = {}, &block)
        column(name, options) do |model|
          val = block ? block.call(model) : model.send(name)
          if options[:i18n]
            I18n.l(val.localtime, options[:i18n])
          else
            I18n.l(val.localtime)
          end
        end
      end

      def column_i18n(name, options = {}, &block)
        column(name, options) do |model|
          val = block ? block.call(model) : model.send(name)
          if options[:i18n]
            I18n.l(val, options[:i18n])
          else
            I18n.l(val)
          end
        end
      end
    end
  end
end
