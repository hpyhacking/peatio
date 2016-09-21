class DepositAcceptMessage

  def take_sms_info(business_id)
    deposit = Deposit.find(business_id)
    sms_message = I18n.t('sms.deposit_done', email: deposit.member.email,
                                             currency: deposit.currency_text,
                                             time: I18n.l(Time.now),
                                             amount: deposit.amount,
                                             balance: deposit.account.balance)

    member = deposit.member
    return member,sms_message
  end

  def take_email_info(business_id)
    return business_id
  end

end
