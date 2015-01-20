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
      markets_h      = $('#market_list').height() + BORDER_WIDTH
      entry_h        = $('#ask_entry').height() + 2*BORDER_WIDTH
      depths_h       = $('#depths_wrapper').height() + 2*BORDER_WIDTH
      my_orders_h    = $('#my_orders').height() + 2*BORDER_WIDTH
      ticker_h       = $('#ticker').height() + 2*BORDER_WIDTH

      # Adjust heights first. Because scrollbar may be removed after heights
      # adjustment, window width will be affected.
      window_h = $(@).height()
      $('.content').height(window_h - navbar_h)

      $('#candlestick').height(window_h - navbar_h - gutter_3x)

      order_h = window_h - navbar_h - entry_h - depths_h - my_orders_h - ticker_h - gutter_6x - 2*BORDER_WIDTH
      $('#order_book').height(order_h)
      $('#order_book .panel-body-content').height(order_h - panel_table_header_high - 2*PANEL_PADDING)

      trades_h = window_h - navbar_h - markets_h - gutter_3x - BORDER_WIDTH
      $('#market_trades').height(trades_h)
      $('#market_trades .panel').height(trades_h - 2*BORDER_WIDTH)
      $('#market_trades .panel-body-content').height(trades_h - 2*BORDER_WIDTH - panel_table_header_high - 2*PANEL_PADDING)

      # Adjust widths.
      window_w     = window.innerWidth
      markets_w    = $('#market_list').width()
      order_book_w = $('#order_book').width()
      $('#candlestick').width(window_w - order_book_w - markets_w - gutter_4x - 20)

    @$node.resize()
