class TwoFactorAppMessage

  #def take_sms_info(business_id,extra_parameter)
  #  member = Member.find(business_id)
  #  sms_message = I18n.t('sms.verification_code', code: extra_parameter)
  #  phone_number = member.phone_number
  #  return phone_number,sms_message
  #end

  def take_email_info(business_id)
    return business_id
  end

end
