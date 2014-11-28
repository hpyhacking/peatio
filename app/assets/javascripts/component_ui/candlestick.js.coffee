if gon.local is "zh-CN"
  DATETIME_LABEL_FORMAT_FOR_TOOLTIP =
    millisecond: ['%m月%e日, %H:%M:%S.%L', '%m月%e日, %H:%M:%S.%L', '-%H:%M:%S.%L']
    second:      ['%m月%e日, %H:%M:%S', '%m月%e日, %H:%M:%S', '-%H:%M:%S']
    minute:      ['%m月%e日, %H:%M', '%m月%e日, %H:%M', '-%H:%M']
    hour:        ['%m月%e日, %H:%M', '%m月%e日, %H:%M', '-%H:%M']
    day:         ['%m月%e日, %H:%M', '%m月%e日, %H:%M', '-%H:%M']
    week:        ['%Y年%m月%e日', '%Y年%m月%e日', '-%m月%e日']
    month:       ['%Y年%m月', '%Y年%m月', '-%m']
    year:        ['%Y', '%Y', '-%Y']

DATETIME_LABEL_FORMAT =
  second: '%H:%M:%S'
  minute: '%H:%M'
  hour: '%H:%M'
  day: '%m-%d'
  week: '%m-%d'
  month: '%Y-%m'
  year: '%Y'

DATE_RANGE =
  min1:
    default_range: 1000 * 3600 * 2 # 2h
    dataGrouping_units: [['minute', [1]]]
  min5:
    default_range: 1000 * 3600 * 10 # 10h
    dataGrouping_units: [['minute', [5]]]
  min15:
    default_range: 1000 * 3600 * 24 * 1 # 1d
    dataGrouping_units: [['minute', [15]]]
  min30:
    default_range: 1000 * 3600 * 24 * 2 # 2d
    dataGrouping_units: [['minute', [30]]]
  min60:
    default_range: 1000 * 3600 * 24 * 5 # 5d
    dataGrouping_units: [['hour', [1]]]
  min120:
    default_range: 1000 * 3600 * 24 * 10 # 10d
    dataGrouping_units: [['hour', [2]]]
  min240:
    default_range: 1000 * 3600 * 24 * 20 # 20d
    dataGrouping_units: [['hour', [4]]]
  min360:
    default_range: 1000 * 3600 * 24 * 30 * 1 # 1m
    dataGrouping_units: [['hour', [6]]]
  min720:
    default_range: 1000 * 3600 * 24 * 30 * 2 # 2m
    dataGrouping_units: [['hour', [12]]]
  min1440:
    default_range: 1000 * 3600 * 24 * 30 * 3 # 3m
    dataGrouping_units: [['day', [1]]]
  min4320:
    default_range: 1000 * 3600 * 24 * 30 * 9 # 9m
    dataGrouping_units: [['day', [3]]]
  min10080:
    default_range: 1000 * 3600 * 24 * 30 * 12 # 12m
    dataGrouping_units: [['day', [7]]]

RANGE_DEFAULT =
  fill: 'none',
  stroke: 'none',
  'stroke-width': 0,
  r: 8,
  style:
    color: '#333',
  states:
    hover:
      fill: '#000',
      style:
        color: '#ccc'
    select:
      fill: '#000',
      style:
        color: '#eee'

INDICATOR = {MA: false, EMA: false}

@CandlestickUI = flight.component ->
  @mask = ->
    @$node.find('.mask').show()

  @unmask = ->
    @$node.find('.mask').hide()

  @request = ->
    @mask()

  @init = (event, data) ->
    @running = true
    @$node.find('#candlestick_chart').highcharts()?.destroy()

    @initHighStock(data)
    @initTooltip()
    @trigger 'market::candlestick::created', data

  @switch = (event, data) ->
    INDICATOR[key] = false for key, val of INDICATOR
    INDICATOR[data.x] = true

    if chart = @$node.find('#candlestick_chart').highcharts()
      for indicator, visible of INDICATOR
        for s in chart.series
          if s.userOptions.algorithm? && (s.userOptions.algorithm == indicator)
            s.setVisible(visible, false)
      chart.redraw()

  @initTooltip = ->
    chart = @$node.find('#candlestick_chart').highcharts()
    tooltips = []
    for i in [0..1]
      if chart.series[i].points.length > 0
        tooltips.push chart.series[i].points[chart.series[i].points.length - 1]
    chart.tooltip.refresh tooltips if tooltips.length

  @initHighStock = (data) ->
    range = DATE_RANGE["min#{data['minutes']}"]['default_range']
    unit = $("[data-unit=#{data['minutes']}]").text()
    title = "#{gon.market.base_unit.toUpperCase()}/#{gon.market.quote_unit.toUpperCase()} - #{unit}"

    dataGrouping =
      enabled: false
      units: DATE_RANGE["min#{data['minutes']}"]['dataGrouping_units']

    if DATETIME_LABEL_FORMAT_FOR_TOOLTIP
        dataGrouping['dateTimeLabelFormats'] = DATETIME_LABEL_FORMAT_FOR_TOOLTIP

    component = @
    @$node.find('#candlestick_chart').highcharts "StockChart",
      chart:
        events:
          load: =>
            @unmask()
        animation: true
        marginTop: 95
        backgroundColor: 'rgba(0,0,0, 0.0)'

      credits:
        enabled: false

      tooltip:
        crosshairs: [{
            width: 0.5,
            dashStyle: 'solid',
            color: '#777'
        }, false],
        valueDecimals: gon.market.bid.fixed
        borderWidth: 0
        backgroundColor: 'rgba(0,0,0,0)'
        borderRadius: 2
        shadow: false
        useHTML: true
        shared: true
        headerFormat: "<div class='chart-ticker'><span class='tooltip-title'>{point.key}</span><br />"
        footerFormat: '<ul></div>'
        positioner: -> {x: 0, y: 0}

      plotOptions:
        candlestick:
          turboThreshold: 0
          followPointer: true
          color: '#990f0f'
          upColor: '#000000'
          lineColor: '#cc1414'
          upLineColor: '#49c043'
          dataGrouping: dataGrouping
          tooltip:
            pointFormat:
              """
              <div class='tooltip-ticker'><span class=t-title>#{gon.i18n.chart.open}</span><span class=t-value>{point.open}</span></div>
              <div class='tooltip-ticker'><span class=t-title>#{gon.i18n.chart.close}</span><span class=t-value>{point.close}</span></div>
              <div class='tooltip-ticker'><span class=t-title>#{gon.i18n.chart.high}</span><span class=t-value>{point.high}</span></div>
              <div class='tooltip-ticker'><span class=t-title>#{gon.i18n.chart.low}</span><span class=t-value>{point.low}</span></div>
              """
        column:
          turboThreshold: 0
          dataGrouping: dataGrouping
          tooltip:
            pointFormat:
              """
              <div class='tooltip-ticker'><span class=t-title>#{gon.i18n.chart.volume}</span><span class=t-value>{point.y}</span></div><ul class='list-inline'>
              """
        trendline:
          lineWidth: 1
          tooltip:
            pointFormat:
              """
              <li><span style='color: {series.color};'>{series.name}: <b>{point.y}</b></span></li>
              """
        histogram:
          lineWidth: 1
          tooltip:
            pointFormat:
              """
              <li><span style='color: {series.color};'>{series.name}: <b>{point.y}</b></span></li>
              """

      scrollbar:
        buttonArrowColor: '#333'
        barBackgroundColor: '#202020'
        buttonBackgroundColor: '#202020'
        trackBackgroundColor: '#202020'
        barBorderColor: '#2a2a2a'
        buttonBorderColor: '#2a2a2a'
        trackBorderColor: '#2a2a2a'

      rangeSelector:
        enabled: false

      navigator:
        maskFill: 'rgba(32, 32, 32, 0.6)'
        outlineColor: '#333'
        outlineWidth: 1
        xAxis:
          dateTimeLabelFormats: DATETIME_LABEL_FORMAT

      xAxis:
        type: 'datetime',
        dateTimeLabelFormats: DATETIME_LABEL_FORMAT
        lineColor: '#333'
        tickColor: '#333'
        tickWidth: 2
        range: range
        events:
          afterSetExtremes: (e) ->
            if e.trigger == 'navigator' && e.triggerOp == 'navigator-drag'
              if component.liveRange(@.chart) && !component.running
                component.trigger "switch::range_switch::init"

      yAxis: [
        {
          labels:
            enabled: true
            align: 'left'
            rotation: -45
          gridLineColor: '#222'
          gridLineDashStyle: 'ShortDot'
          top: "0%"
          height: "70%"
          lineColor: '#fff'
        }
        {
          labels:
            enabled: false
          top: "70%"
          gridLineColor: '#000'
          height: "15%"
        }
        {
          labels:
            enabled: false
          top: "85%"
          gridLineColor: '#000'
          height: "15%"
        }
      ]

      series: [
        {
          name: gon.i18n.chart.candlestick
          type: "candlestick"
          data: data['candlestick']
          showInLegend: false
        }
        {
          name: gon.i18n.chart.volume
          yAxis: 1
          type: "column"
          data: data['volume']
          color: '#777'
          showInLegend: false
        }
        {
          type: 'spline'
          data: data['close']
          visible: false
          id: 'close'
          showInLegend: false
        }
        {
          name: 'MA5',
          linkedTo: 'close',
          showInLegend: true,
          type: 'trendline',
          algorithm: 'MA',
          periods: 5
          color: '#7c9aaa'
          visible: INDICATOR['MA']
        }
        {
          name: 'MA10'
          linkedTo: 'close',
          showInLegend: true,
          type: 'trendline',
          algorithm: 'MA',
          periods: 10
          color: '#be8f53'
          visible: INDICATOR['MA']
        }
        {
          name: 'EMA7',
          linkedTo: 'close',
          showInLegend: true,
          type: 'trendline',
          algorithm: 'EMA',
          periods: 7
          color: '#7c9aaa'
          visible: INDICATOR['EMA']
        }
        {
          name: 'EMA30',
          linkedTo: 'close',
          showInLegend: true,
          type: 'trendline',
          algorithm: 'EMA',
          periods: 30
          color: '#be8f53'
          visible: INDICATOR['EMA']
        }
        {
          name : 'MACD',
          linkedTo: 'close',
          yAxis: 2,
          showInLegend: true,
          type: 'trendline',
          algorithm: 'MACD'
          color: '#7c9aaa'
        }
        {
          name : 'SIG',
          linkedTo: 'close',
          yAxis: 2,
          showInLegend: true,
          type: 'trendline',
          algorithm: 'signalLine'
          color: '#be8f53'
        }
        {
          name: 'HIST',
          linkedTo: 'close',
          yAxis: 2,
          showInLegend: true,
          type: 'histogram'
          color: '#990f0f'
        }
      ]

  @create = (chart, x, trade) ->
    p = parseFloat(trade.price)
    v = parseFloat(trade.amount)
    @createCandleStick(chart, x, p, v)
    @createVolume(chart, x, p, v)
    @createClose(chart, x, p, v)

  @createCandleStick = (chart, x, p, v) ->
    chart.series[0].addPoint([x, p, p, p, p], false)

  @createVolume = (chart, x, p, v) ->
    chart.series[1].addPoint({x: x, y: v, color: @getTrend(chart.series[0].points[chart.series[0].points.length-1].close, p)}, false)

  @createClose = (chart, x, p, v) ->
    chart.series[2].addPoint([x, p], false)

  @update = (chart, trade) ->
    p = parseFloat(trade.price)
    v = parseFloat(trade.amount)
    trend = @updateCandleStick(chart, p, v)
    @updateVolume(chart, trend, p, v)
    @updateClose(chart, p, v)

  @updateCandleStick = (chart, p, v) ->
    i = chart.series[0].points.length - 1
    point = chart.series[0].points[i]
    ohlc = x: point.x, open: point.open, high: point.high, low: point.low, close: p
    if p > point.high
      ohlc.high = p
    else if p < point.low
      ohlc.low = p
    point.update(ohlc, false)

    @getTrend(chart.series[0].points[i-1].close, point.close)

  @updateVolume = (chart, trend, p, v) ->
    i = chart.series[1].points.length - 1
    point = chart.series[1].points[i]
    point.update({x: point.x, y: point.y+v, color: trend}, false)

  @updateClose = (chart, p, v) ->
    if chart.series[2].points
      i = chart.series[2].points.length - 1
      point = chart.series[2].points[i]
      point.update(p, false)

  @getTrend = (p1, p2) ->
    if p1 < p2 then 'rgba(0, 255, 0, 0.5)' else 'rgba(255, 0, 0, 0.5)'

  @process = (chart, data) ->
    $.each data.trades, (_, trade) =>
      i = chart.series[10].points.length - 1
      ts = trade.date * 1000
      next_ts = chart.series[10].points[i].x + data.minutes*60*1000
      if ts < next_ts
        @update(chart, trade)
      else
        @create(chart, next_ts, trade)

  @updateChart = (event, data) ->
    chart = @$node.find('#candlestick_chart').highcharts()

    if @liveRange(chart)
      @process(chart, data)
      chart.redraw()
    else
      @running = false

  @liveRange = (chart) ->
    p1 = chart.series[0].points[ chart.series[0].points.length-1 ].x
    p2 = chart.series[10].points[ chart.series[10].points.length-1 ].x
    p1 == p2

  @after 'initialize', ->
    @on document, 'market::candlestick::request', @request
    @on document, 'market::candlestick::response', @init
    @on document, 'market::candlestick::update', @updateChart
    @on document, 'switch::main_indicator_switch', @switch
