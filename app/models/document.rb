# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  key        :string(255)
#  title      :string(255)
#  body       :text
#  is_auth    :boolean
#  created_at :datetime
#  updated_at :datetime
#  desc       :text
#  keywords   :text
#

class Document < ActiveRecord::Base
  TRANSLATABLE_ATTR = [:title, :desc, :keywords, :body]
  translates *TRANSLATABLE_ATTR

  def to_param
    self.key
  end

  TRANSLATABLE_ATTR.each do |attr|
    Rails.configuration.i18n.available_locales.each do |locale|
      define_method "#{locale.underscore}_#{attr}=" do |value|
        with_locale locale do
          self.send("#{attr}=", value)
        end
      end

      define_method "#{locale.underscore}_#{attr}" do
        with_locale locale do
          self.send("#{attr}")
        end
      end
    end
  end

  def self.locale_params
    params = []
    TRANSLATABLE_ATTR.each do |attr|
      Rails.configuration.i18n.available_locales.each do |locale|
        params << "#{locale.underscore}_#{attr}".to_sym
      end
    end
    params
  end

  private

  def with_locale locale
    original_locale = I18n.locale
    I18n.locale = locale
    value = yield if block_given?
    I18n.locale = original_locale
    value
  end
end
