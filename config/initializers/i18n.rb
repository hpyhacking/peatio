module ActionView::Helpers::TranslationHelper
  def t_with_default_brand(*args)
    brand = I18n.t('brand', default: 'PEATIO')
    if args.last.is_a?(Hash)
      args.last = args.last ++ {brand: brand}
    else
      args << {brand: brand}
    end
    t_without_default_brand(*args)
  end
  alias_method_chain :t, :default_brand
end

