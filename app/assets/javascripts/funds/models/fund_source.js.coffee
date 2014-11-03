class FundSource extends PeatioModel.Model
  @configure 'FundSource', 'aasm_state', 'member_id', 'currency', 'extra', 'uid', 'is_locked', 'label'

  constructor: ->
    super

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        FundSource.create(record)

window.FundSource = FundSource
