Selectize.define 'option_destroy', ->
  self = @
  @onOptionSelect = ( ->
    original = self.onOptionSelect
    (e) ->
      $target = $(e.target)
      if $target.hasClass('fa-trash-o')
        $.ajax
          url: "/fund_sources/#{encodeURIComponent($target.parent().data('fs-uid'))}"
          type: 'DELETE'
        .done ->
          self.load(self.settings.load)
          self.open()
      else
        original.apply(@, arguments)
  )()

$ ->
  $fund_extra_select = $("form select[name$='[fund_extra]']")
  $fund_uid_select   = $("form select[name$='[fund_uid]']")
  $channel_id_input  = $("form input[name$='[channel_id]']")
  $fund_extra_input  = $("form input[name$='[fund_extra]']")

  sels = $fund_extra_select.selectize()
  $fe_selectize = sels[0]?.selectize

  $fund_uid_select.selectize
    plugins: ['option_destroy']
    persist: false
    createOnBlur: true
    valueField: 'uid'
    labelField: 'extra'
    searchField: ['uid', 'extra']
    create: (input) ->
      extra = $fe_selectize?.getValue()
      {
        uid: input
        extra: extra || ''
      }
    render:
      option: (item, escape) ->
        """<div>
          <div><span>#{escape(item.uid)}</span></div>
          <div>
            <span>#{escape(gon.banks?[item.extra] or item.extra)}</span>
            <a class="destroy-fund-source pull-right" href="javascript:void(0)" data-fs-uid="#{item.uid}">
              <i class="fa fa-trash-o"></i>
            </a>
          </div></div>"""
    load: (query, callback) ->
      [callback, query] = [query, ''] unless callback
      if(query.length < 4)
        $.ajax
          url: "/fund_sources?channel_id=#{$channel_id_input.val()}&query=#{encodeURIComponent(query)}"
          type: 'GET'
          error: -> callback()
          success: (res) =>
            @clearOptions()
            callback(res)

    onItemAdd: (value, $item) ->
      extra = $item.text()
      $item.text(value)
      $fund_extra_input.val(extra)

      $fe_selectize?.setValue(extra)
