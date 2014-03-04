class Document < ActiveRecord::Base
  TRANSLATABLE_ATTR = [:title, :body]
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

  private

  def with_locale locale
    original_locale = I18n.locale
    I18n.locale = locale
    value = yield if block_given?
    I18n.locale = original_locale
    value
  end
end
