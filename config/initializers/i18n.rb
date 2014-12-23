### monkey patch for default brand when i18n interpolate value.
### NEVER direct use brand in I18n.t function.

module I18n
  class<< self
    def t_with_default_brand(*args)
      brand = t_without_default_brand('brand', default: 'PEATIO')

      if args.last.is_a?(Hash)
        args[-1] = args.last.merge brand: brand
      else
        args << {brand: brand}
      end
      t_without_default_brand(*args)
    end
    alias_method_chain :t, :default_brand
  end
end

module I18n
  module Backend
    module Base

      def interpolate_with_default_brand(locale, string, values = {})
        values.delete :brand unless string =~ /%\{brand\}/
        interpolate_without_default_brand(locale, string, values)
      end

      alias_method_chain :interpolate, :default_brand
    end
  end
end
