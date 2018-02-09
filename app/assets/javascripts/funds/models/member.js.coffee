class Member extends PeatioModel.Model
  @configure 'Member', 'sn', 'created_at', 'updated_at'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Member.create(record)

window.Member = Member
