@MarketChartUI = flight.component ->
  @drawChart = ->
    dataGrouping =
      focus: true
      units: [['minute', [1, 3, 5, 15, 30]], ['hour', [1]]]

    @$node.highcharts "StockChart",
      chart:
        backgroundColor: '#202020'
        events:
          load: ->
            formatOhlc = (data) ->
              [
                Number(data[0]) * 1000  # date
                data[1]                 # open
                data[2]                 # high
                data[3]                 # low
                data[4]                 # close
              ]

            formatVolume = (data) ->
              [
                Number(data[0]) * 1000  # date
                data[5]                 # volume
              ]

            fetchData = (limit=5, callback) ->
              url = "/api/v2/k.json?market=#{gon.market.id}&limit=#{limit}&period=1"
              $.getJSON url, (data) =>
                ohlc   = []
                volume = []

                for i in data
                  ohlc.push formatOhlc(i)
                  volume.push formatVolume(i)

                if callback
                  callback ohlc: ohlc, volume: volume


            fetchData 5000, (data) =>
              @series[0].setData data.ohlc
              @series[1].setData data.volume

            setInterval =>
              fetchData 5000, (data) =>
                @series[0].setData data.ohlc, false
                @series[1].setData data.volume, false
                @redraw()
            , 60 * 1000

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
          count: 100,
          text: "1#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 300,
          text: "3#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 500,
          text: "5#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 1500,
          text: "15#{gon.i18n.time.minute}"
        ,
          type: 'minute',
          count: 3000,
          text: "30#{gon.i18n.time.minute}"
        ,
          type: 'hour',
          count: 100,
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
          top: "80%"
          height: "20%"
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

  @after 'initialize', ->
    @drawChart()
