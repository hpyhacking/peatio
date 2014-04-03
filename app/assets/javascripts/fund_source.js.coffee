$(->
  Selectize.define 'option_destroy', ->
    self = @
    @onOptionSelect = ( ->
      original = self.onOptionSelect
      (e) ->
        $target = $(e.target)
        if $target.hasClass('glyphicon-trash')
          $.ajax
            url: "/fund_sources/#{$target.parent().data('addr-id')}"
            type: 'DELETE'
          .done ->
            self.load(self.settings.load)
            self.open()
        else
          original.apply(@, arguments)
    )()

  sels = $("select[name$='[fund_extra]']").selectize()
  $("select[name$='[fund_uid]']").selectize
    plugins: ['option_destroy']
    preload: true
    persist: false
    createOnBlur: true
    valueField: 'uid'
    labelField: 'extra'
    searchField: ['uid', 'extra']
    create: (input) ->
      extra = sels[0]?.selectize.getValue()
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
            <a class="destroy-fund-source pull-right" href="javascript:void(0)" data-addr-id="#{item.id}">
              <span class="glyphicon glyphicon-trash"></span>
            </a>
          </div></div>"""
    load: (query, callback) ->
      [callback, query] = [query, ''] unless callback
      if(query.length < 4)
        $.ajax
          url: "/fund_sources?channel_id=#{$("input[name$='[channel_id]']").val()}&query=#{encodeURIComponent(query)}"
          type: 'GET'
          error: -> callback()
          success: (res) =>
            @clearOptions()
            callback(res)

    onItemAdd: (value, $item) ->
      extra = $item.text()
      $item.text(value)
      $("form input[name$='[fund_extra]']").val(extra)

      sels[0].selectize.setValue(extra) if sels[0]
)
