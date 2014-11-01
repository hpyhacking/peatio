class FundSource extends PeatioModel.Model
  @configure 'FundSource', 'aasm_state', 'member_id', 'currency', 'extra', 'uid', 'is_locked', 'label'

  constructor: ->
    super
    @label = "#{@uid}(#{@bank_name(@extra)})"

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        FundSource.create(record)

  bank_name: (code) ->
    I18n.t "banks.#{code}"

window.FundSource = FundSource
