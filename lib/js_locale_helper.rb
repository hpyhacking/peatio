# encoding: UTF-8
# frozen_string_literal: true

module JsLocaleHelper

  def self.load_yaml(locale)
    locale_str = locale.to_s
    trans        = YAML::load(File.open("#{Rails.root}/config/locales/client.#{locale_str}.yml"))[locale_str]['js']
    {locale_str => trans}
  rescue => e
    report_exception(e)
    {locale_str => {}}
  end

  def self.output_locale(locale = :en)
    "I18n.translations = #{load_yaml(locale).to_json};
     I18n.locale = '#{locale}';"
  end

end
