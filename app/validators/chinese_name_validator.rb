class ChineseNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value =~ /[a-zA-Z0-9]/
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.id_documents.name_invalid'))
    end
  end
end
