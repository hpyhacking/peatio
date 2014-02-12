class StrengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    min = options[:min]
    min ||= 6
    unless value =~ /(?=^.{#{min},}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*\z/
      record.errors[attribute] << (options[:message] || I18n.t("activemodel.errors.messages.strength"))
    end
  end
end

