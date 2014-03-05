def deposit admin_identity, member, amount
    login admin_identity
    click_on 'admin'

    # this part is handled by a google extension
    query = {deposit: { tx_id: "deposit_#{Time.now.to_i}",
              sn: member.sn,
              address: identity.email,
              address_label: member.name,
              address_type: 'bank',
              amount: amount }}

    visit(new_admin_currency_deposit_path(query))

    within 'form' do
      click_on I18n.t('helpers.submit.deposit.create')
    end

    expect(page).to have_content(I18n.t('admin.currency_deposits.create.success'))
end
