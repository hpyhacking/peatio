class FundSource extends PeatioModel.Model
  @configure 'FundSource', 'member_id', 'currency', 'extra', 'uid', 'is_locked'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        FundSource.create(record)

window.FundSource = FundSource
