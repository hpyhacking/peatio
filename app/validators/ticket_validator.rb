class TicketValidator < ActiveModel::Validator
  def validate(record)
    if record.title.blank? && record.content.blank?
      record.errors[:title] << I18n.t('private.tickets.title_content_both_blank')
    end
  end
end
