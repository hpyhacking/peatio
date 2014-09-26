class FundSource extends PeatioModel.Model
  @configure 'FundSource', 'member_id', 'currency', 'extra', 'uid', 'is_locked', 'label'

  constructor: ->
    super
    @label = "#{@uid}(#{@extra})"

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        FundSource.create(record)

window.FundSource = FundSource
