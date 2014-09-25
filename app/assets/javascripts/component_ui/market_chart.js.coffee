@MarketChartUI = flight.component ->

  @initMarketChart = ->
    updateData = (callback) =>
      $.getJSON "/api/v2/k.json?market=#{gon.market.id}&limit=5&period=1", (data) =>
        gon.kline_data = gon.kline_data.concat data
        do callback

    dataGrouping = [
      ['minute', [1,2,5,10,15,30]]
      ['hour',[1,2,5,10]]
    ]

    @$node.highcharts "StockChart",
      credits:
        enabled: false

      chart:
        height: 360
        events:
          load: ->
            drawChart = =>
              ohlc   = []
              volume = []

              for i in gon.kline_data
                ohlc.push [
                  Number(i[0]) * 1000 # the date
                  i[1] # open
                  i[2] # high
                  i[3] # low
                  i[4] # close
                ]
                volume.push [
                  Number(i[0]) * 1000 # the date
                  i[5] # the volume
                ]

              @series[0].setData ohlc
              @series[1].setData volume

            drawChart()
            setInterval ->
              updateData(drawChart)
            , 5 * 60 * 1000

      navigator:
        top: 300

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
        inputEnabled: true
        selected: 4
        buttons: [
          type: 'minute',
          count: 5,
          text: "5#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 15,
          text: "15#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 30,
          text: "30#{gon.i18n.time.minute}"
        ,
          type: 'hour',
          count: 60,
          text: gon.i18n.time.hour
        ]

      yAxis: [
        {
          opposite: false
          height: 160
          lineWidth: 2
        }
        {
          opposite: false
          top: 185
          height: 60
          offset: 0
          lineWidth: 2
        }
      ]

      series: [
        {
          type: "candlestick"
          dataGrouping:
            smoothed: true
        }
        {
          type: "column"
          name: gon.i18n.chart.volume
          yAxis: 1
        }
      ]

  @after 'initialize', ->
    @initMarketChart()
