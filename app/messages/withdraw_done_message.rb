class WithdrawDoneMessage

  def take_sms_info(business_id)
    withdraw = Withdraw.find(business_id)
    sms_message = I18n.t('sms.withdraw_done', email: withdraw.member.email,
                                              currency: withdraw.currency_text,
                                              time: I18n.l(Time.now),
                                              amount: withdraw.amount,
                                              balance: withdraw.account.balance)

    member = withdraw.member
    return member,sms_message
  end

  def take_email_info(business_id)
    return business_id
  end

end
