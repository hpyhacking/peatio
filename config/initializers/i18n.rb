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
