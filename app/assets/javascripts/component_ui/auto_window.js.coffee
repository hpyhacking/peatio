GUTTER = 2 # linkage to market.css.scss $gutter var
PANEL_TABLE_HEADER_HIGH = 37
PANEL_PADDING = 8
BORDER_WIDTH = 1

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
    panel_table_header_high = PANEL_TABLE_HEADER_HIGH

    @$node.resize ->
      navbar_h       = $('.navbar').height() + BORDER_WIDTH
      entry_h        = $('#ask_entry').height() + 2*BORDER_WIDTH
      depths_h       = $('#depths_wrapper').height() + 2*BORDER_WIDTH
      my_orders_h    = $('#my_orders').height() + 2*BORDER_WIDTH
      ticker_h       = $('#ticker').height() + 2*BORDER_WIDTH
      order_book_w   = $('#order_book').width()

      # Adjust heights first. Because scrollbar may be removed after heights
      # adjustment, window width will be affected.
      window_h = $(@).height()
      $('.content').height(window_h - navbar_h)

      $('#candlestick').height(window_h - navbar_h - gutter_3x)

      order_h = window_h - navbar_h - entry_h - depths_h - my_orders_h - ticker_h - gutter_6x - 2*BORDER_WIDTH
      $('#order_book').height(order_h)
      $('#order_book .panel-body-content').height(order_h - panel_table_header_high - 2*PANEL_PADDING)

      unless $('#chat_tabs_wrapper').hasClass('stop-resize')
        switch_h = $('#market_switch_tabs_wrapper').height()
        $('#chat_tabs_wrapper').height(window_h - navbar_h - switch_h - gutter_9x)

      # Adjust widths.
      window_w = $(@).width()
      $('#candlestick').width(window_w - order_book_w - gutter_2x)

    @$node.resize()
