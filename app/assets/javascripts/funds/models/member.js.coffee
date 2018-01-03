class Member extends PeatioModel.Model
  @configure 'Member', 'sn', 'display_name', 'created_at', 'updated_at', 'state',
    'country_code', 'phone_number', 'name'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Member.create(record)

window.Member = Member
