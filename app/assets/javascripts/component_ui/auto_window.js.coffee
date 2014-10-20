GUTTER = 2 # linkage to market.css.scss $gutter var
NAV_STACKED_WIDTH = 50 # linkage to market.css.scss $nav_stacked_width var
PANEL_TABLE_HEADER_HIGH = 73

@AutoWindowUI = flight.component ->
  @after 'initialize', ->
    gutter = GUTTER
    gutter_2x = GUTTER * 2
    gutter_3x = GUTTER * 3
    gutter_4x = GUTTER * 4
    gutter_5x = GUTTER * 5
    gutter_6x = GUTTER * 6
    gutter_7x = GUTTER * 7
    gutter_8x = GUTTER * 8
    gutter_9x = GUTTER * 9
    nav_stacked_width = NAV_STACKED_WIDTH
    nav_stacked_width_2x = NAV_STACKED_WIDTH * 2
    panel_table_header_high = PANEL_TABLE_HEADER_HIGH

    @$node.resize ->
      navbar_h = $('.navbar').height() + 1
      window_w = $(@).width()
      window_h = $(@).height()
      entry_h = $('#ask_entry').height()
      order_book_w = $('#order_book').width()

      $('.content').width(window_w)
      $('.content').height(window_h - navbar_h)

      $('#candlestick').width(window_w - order_book_w - gutter_3x - nav_stacked_width_2x)
      $('#candlestick').height(window_h - navbar_h - gutter_3x)

      $('#order_book').height(window_h - navbar_h - entry_h - gutter_5x)
      $('#order_book .panel-body-content').height(window_h - navbar_h - entry_h - panel_table_header_high - gutter_5x)

      unless $('#chat_tabs_wrapper').hasClass('stop-resize')
        switch_h = $('#market_switch_tabs_wrapper').height()
        $('#chat_tabs_wrapper').height(window_h - navbar_h - switch_h - gutter_9x)

    @$node.resize()
