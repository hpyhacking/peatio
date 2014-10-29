module JsLocaleHelper

  def self.load_yaml(locale)
    locale_str = locale.to_s
    translations = YAML::load(File.open("#{Rails.root}/config/locales/client.#{locale_str}.yml"))[locale_str]['js']
    {locale_str => translations}
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
