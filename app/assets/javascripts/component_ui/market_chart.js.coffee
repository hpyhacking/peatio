@MarketChartUI = flight.component ->

  dataGrouping = [
    ['minute', [1,5,10,15,30,60]]
    ['hour',[1,2,5,10]]
  ]

  @attributes
    chartOptions:
      credits:
        enabled: false

      tooltip:
        valueDecimals: gon.market.bid.fixed
        backgroundColor:
          linearGradient:
            x1: 0
            y1: 0
            x2: 0
            y2: 1
          stops: [
            [0, 'white'],
            [1, '#EEE']
          ]
        borderColor: 'gray'
        borderWidth: 1

      plotOptions:
        candlestick:
          animation: true
          color: 'red'
          upColor: 'green'
          dataGrouping: dataGrouping
          tooltip:
            pointFormat:
              """
              #{gon.i18n.chart.open}: {point.open}<br/>
              #{gon.i18n.chart.high}: {point.high}<br/>
              #{gon.i18n.chart.low}: {point.low}<br/>
              #{gon.i18n.chart.close}: {point.close}<br/>
              """
        column:
          color: '#3e4c5a'
          dataGrouping: dataGrouping
          tooltip:
            pointFormat:
              """
              #{gon.i18n.chart.volume}: {point.y}<br/>
              """

      rangeSelector:
        allButtonsEnabled: true
        inputEnabled: false
        selected: 4
        buttons: [
          type: 'minute',
          count: 10,
          text: "1#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 30,
          text: "5#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 60,
          text: "15#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 120,
          text: "30#{gon.i18n.time.minute}"
        ,
          type: 'hour',
          count: 180,
          text: gon.i18n.time.hour
        ]

      yAxis: [
        {
          opposite: false
          labels:
            enabled: false
        }
        {
          opposite: false
          labels:
            enabled: false
          top: "82%"
          height: "18%"
        }
      ]

      series: [
        {
          type: "candlestick"
        }
        {
          type: "column"
          yAxis: 1
        }
      ]

  @fetchData = (limit=5, callback) ->
    url = "/api/v2/k.json?market=#{gon.market.id}&limit=#{limit}&period=1"
    $.getJSON url, (data) -> callback(data)

  @formatOhlc = (data) ->
    [
      Number(data[0]) * 1000  # date
      data[1]                 # open
      data[2]                 # high
      data[3]                 # low
      data[4]                 # close
    ]

  @formatVolume = (data) ->
    [
      Number(data[0]) * 1000  # date
      data[5]                 # volume
    ]

  @drawChart = ->
    @fetchData 5000, (data) =>
      ohlc   = []
      volume = []

      for i in data
        ohlc.push @formatOhlc(i)
        volume.push @formatVolume(i)

      @attr.chartOptions.series[0].data = ohlc
      @attr.chartOptions.series[1].data = volume

      @$node.highcharts "StockChart", @attr.chartOptions

  @after 'initialize', ->
    @drawChart()
