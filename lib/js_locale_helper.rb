module JsLocaleHelper

  def self.load_yaml(locale)
    YAML::load(File.open("#{Rails.root}/config/locales/client.#{locale}.yml"))['js']
  rescue
    {}
  end

  def self.output_locale(locale=:en)
    result = ""
    result << "I18n.translations = #{load_yaml(locale).to_json};\n"
    result << "I18n.locale = '#{locale}';\n"
    result
  end

end
