module JsLocaleHelper

  def self.load_yaml(locale)
    locale_str = locale.to_s
    translations = I18n.backend.send :translations
    {locale_str => translations[locale_str.to_sym][:js]}
  rescue
    {locale_str => {}}
  end

  def self.output_locale(locale=:en)
    result = ""
    result << "I18n.translations = #{load_yaml(locale).to_json};\n"
    result << "I18n.locale = '#{locale}';\n"
    result
  end

end
