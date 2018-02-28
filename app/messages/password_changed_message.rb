class PasswordChangedMessage

  def take_sms_info(business_id)
    member = Member.find(business_id)
    sms_message = I18n.t('sms.password_changed', email: member.email)
    return member,sms_message
  end

  def take_email_info(business_id)
    return business_id
  end

end
