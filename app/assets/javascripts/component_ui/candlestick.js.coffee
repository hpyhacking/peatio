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

TYPE      = {candlestick: false, close: false}
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
    @initTooltip @$node.find('#candlestick_chart').highcharts()
    @trigger 'market::candlestick::created', data

  @switchType = (event, data) ->
    TYPE[key] = false for key, val of TYPE
    TYPE[data.x] = true

    if chart = @$node.find('#candlestick_chart').highcharts()
      for type, visible of TYPE
        for s in chart.series
          if !s.userOptions.algorithm? && (s.userOptions.id == type)
            s.setVisible(visible, false)
      @trigger "switch::main_indicator_switch::init"
      @initTooltip chart

  @switchMainIndicator = (event, data) ->
    INDICATOR[key] = false for key, val of INDICATOR
    INDICATOR[data.x] = true

    if chart = @$node.find('#candlestick_chart').highcharts()
      # reset all series depend on close
      for s in chart.series
        if s.userOptions.linkedTo == 'close'
          s.setVisible(true, false)

      for indicator, visible of INDICATOR
        for s in chart.series
          if s.userOptions.algorithm? && (s.userOptions.algorithm == indicator)
            s.setVisible(visible, false)
      chart.redraw()

  @initTooltip = (chart) ->
    tooltips = []
    if chart.series[0].points.length > 0
      tooltips.push chart.series[0].points[chart.series[0].points.length-1]
    chart.tooltip.refresh tooltips if tooltips.length

  @initHighStock = (data) ->
    component = @
    range = DATE_RANGE["min#{data['minutes']}"]['default_range']
    unit = $("[data-unit=#{data['minutes']}]").text()
    title = "#{gon.market.base_unit.toUpperCase()}/#{gon.market.quote_unit.toUpperCase()} - #{unit}"

    timeUnits =
      millisecond: 1
      second: 1000
      minute: 60000
      hour: 3600000
      day: 24 * 3600000
      week: 7 * 24 * 3600000
      month: 31 * 24 * 3600000
      year: 31556952000

    dataGrouping =
      enabled: false
      units: DATE_RANGE["min#{data['minutes']}"]['dataGrouping_units']

    tooltipTemplate = JST["templates/tooltip"]

    if DATETIME_LABEL_FORMAT_FOR_TOOLTIP
        dataGrouping['dateTimeLabelFormats'] = DATETIME_LABEL_FORMAT_FOR_TOOLTIP

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
        shared: true
        positioner: -> {x: 0, y: 0}
        useHTML: true
        formatter: ->
          chart  = @points[0].series.chart
          series = @points[0].series
          index  = @points[0].point.index
          key    = @points[0].key

          for k, v of timeUnits
            if v >= series.xAxis.closestPointRange || (v <= timeUnits.day && key % v > 0)
              title = Highcharts.dateFormat DATETIME_LABEL_FORMAT_FOR_TOOLTIP[k][0], key
              break

          fun = (h, s) ->
            h[s.options.id] = s.data[index]
            h
          tooltipTemplate
            title:  title
            indicator: INDICATOR
            format: (v) -> Highcharts.numberFormat v, 2
            points: _.reduce chart.series, fun, {}

      plotOptions:
        candlestick:
          turboThreshold: 0
          followPointer: true
          color: '#990f0f'
          upColor: '#000000'
          lineColor: '#cc1414'
          upLineColor: '#49c043'
          dataGrouping: dataGrouping
        column:
          turboThreshold: 0
          dataGrouping: dataGrouping
        trendline:
          lineWidth: 1
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
          id: 'candlestick'
          name: gon.i18n.chart.candlestick
          type: "candlestick"
          data: data['candlestick']
          showInLegend: false
          visible: TYPE['candlestick']
        }
        {
          id: 'close'
          type: 'spline'
          data: data['close']
          showInLegend: false
          visible: TYPE['close']
        }
        {
          id: 'volume'
          name: gon.i18n.chart.volume
          yAxis: 1
          type: "column"
          data: data['volume']
          color: '#777'
          showInLegend: false
        }
        {
          id: 'ma5'
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
          id: 'ma10'
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
          id: 'ema7'
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
          id: 'ema30'
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
          id: 'macd'
          name : 'MACD',
          linkedTo: 'close',
          yAxis: 2,
          showInLegend: true,
          type: 'trendline',
          algorithm: 'MACD'
          color: '#7c9aaa'
        }
        {
          id: 'sig'
          name : 'SIG',
          linkedTo: 'close',
          yAxis: 2,
          showInLegend: true,
          type: 'trendline',
          algorithm: 'signalLine'
          color: '#be8f53'
        }
        {
          id: 'hist'
          name: 'HIST',
          linkedTo: 'close',
          yAxis: 2,
          showInLegend: true,
          type: 'histogram'
          color: '#990f0f'
        }
      ]

  @formatPointArray = (point) ->
    x: point[0], open: point[1], high: point[2], low: point[3], close: point[4]

  @createPoint = (chart, data, i) ->
    chart.series[0].addPoint(data.candlestick[i], false)
    chart.series[1].addPoint(data.close[i], false)
    chart.series[2].addPoint(data.volume[i], false)
    chart.redraw(true)

  @updatePoint = (chart, data, i) ->
    chart.series[0].points[chart.series[0].points.length-1].update(@formatPointArray(data.candlestick[i]), false)
    chart.series[1].points[chart.series[1].points.length-1].update(data.close[i][1], false) if chart.series[1].points
    chart.series[2].points[chart.series[2].points.length-1].update(data.volume[i], false)
    chart.redraw(true)

  @process = (chart, data) ->
    for i in [0..(data.candlestick.length-1)]
      current = chart.series[0].points.length - 1
      current_point = chart.series[0].points[current]

      if data.candlestick[i][0] > current_point.x
        @createPoint chart, data, i
      else if data.candlestick[i][0] == current_point.x
        @updatePoint chart, data, i
      else
        # ignore obsolete point

  @updateByTrades = (event, data) ->
    chart = @$node.find('#candlestick_chart').highcharts()

    if @liveRange(chart)
      @process(chart, data)
    else
      @running = false

  @liveRange = (chart) ->
    p1 = chart.series[0].points[ chart.series[0].points.length-1 ].x
    p2 = chart.series[10].points[ chart.series[10].points.length-1 ].x
    p1 == p2

  @after 'initialize', ->
    @on document, 'market::candlestick::request', @request
    @on document, 'market::candlestick::response', @init
    @on document, 'market::candlestick::trades', @updateByTrades
    @on document, 'switch::main_indicator_switch', @switchMainIndicator
    @on document, 'switch::type_switch', @switchType
