ESC = 27
@KeyBindUI = flight.component ->
  @after 'initialize', ->
    entry = '#ask_entry'
    @$node.on 'keyup', (e) ->
      if e.keyCode == ESC
        if entry == '#bid_entry' then entry = '#ask_entry' else entry = '#bid_entry'
        $(entry).trigger 'place_order::clear'
