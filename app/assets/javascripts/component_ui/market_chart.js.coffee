@MarketChartUI = flight.component ->

  @drawChart = ->
    @$node.highcharts "StockChart",
      credits:
        enabled: false

      chart:
        height: 360
        events:
          load: ->
            series = @series
            update = ->
              $.getJSON "https://peatio.com/api/v2/k.json?market=#{gon.market.id}&limit=45&period=1", (data) ->

                ohlc   = []
                volume = []

                for i in data
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

                series[0].setData ohlc
                series[1].setData volume

            update()
            setInterval ->
              update
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
          color: 'red'
          upColor: 'green'
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
          tooltip:
            pointFormat:
              """
              #{gon.i18n.chart.volume}: {point.y}<br/>
              """

      rangeSelector:
        inputEnabled: false
        selected: true
        buttons: [
          {
            type: 'hour',
            count: 4,
            text: '4h'
          }, {
            type: 'hour',
            count: 12,
            text: '12h'
          }
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
          name: "#{gon.market.base_unit}/#{gon.market.quote_unit}".toUpperCase()
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
    @drawChart()
