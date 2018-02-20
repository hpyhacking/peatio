def deposit(admin_identity, member, amount)
  sign_in admin_identity
  click_on 'admin'

  # this part is handled by a google extension
  query = { deposit: { txid: "deposit_#{Time.now.to_i}",
                       sn: member.sn,
                       fund_uid: identity.email,
                       fund_extra: member.email,
                       amount: amount } }

  visit(new_admin_currency_deposit_path(query))

  within 'form' do
    click_on I18n.t('helpers.submit.deposit.create')
  end
end
