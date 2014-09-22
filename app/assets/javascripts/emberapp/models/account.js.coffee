class Account extends PeatioModel.Model
  @configure 'Account', 'member_id', 'currency', 'balance', 'locked', 'created_at', 'updated_at', 'in', 'out'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Account.create(record)

window.Account = Account
