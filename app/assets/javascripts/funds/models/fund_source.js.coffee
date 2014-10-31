class FundSource extends PeatioModel.Model
  @configure 'FundSource', 'member_id', 'currency', 'extra', 'uid', 'is_locked', 'label'

  constructor: ->
    super
    @label = "#{@uid}(#{@bank_name(@extra)})"

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        FundSource.create(record)

  bank_name: (code) ->
    switch code
      when 'icbc' then "工商银行"
      when 'cbc'  then "建设银行"
      when 'bc'   then "中国银行"
      when 'bcm'  then "交通银行"
      when 'abc'  then "农业银行"
      when 'cmb'  then "招商银行"
      when 'cmbc' then "民生银行"
      when 'cncb' then "中信银行"
      when 'hxb'  then "华夏银行"
      when 'cib'  then "兴业银行"
      when 'spdb' then "浦东发展银行"
      when 'bob'  then "北京银行"
      when 'ceb'  then "光大银行"
      when 'sdb'  then "深圳发展银行"
      when 'pab'  then "平安银行"
      when 'gdb'  then "广东发展银行"
      else code

window.FundSource = FundSource
