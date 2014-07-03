class ChineseIdCardNumValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /(^\d{15}$)|(^\d{17}([0-9]|X)$)/
      record.errors[attribute] << (options[:message] || I18n.t('activerecord.errors.messages.id_documents.sn_invalid'))
    end
  end
end
