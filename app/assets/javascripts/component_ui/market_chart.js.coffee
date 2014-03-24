@MarketChartUI = flight.component ->

  @drawChart = ->
    @$node.highcharts "StockChart",
      chart:
        events:
          load: ->
            series = @series
            update = ->
              $.getJSON "/api/prices/#{gon.market.id}", (data) ->
                price  = []
                volume = []

                for i in gon.price
                  price.push [
                    Number(i.date) * 1000
                    Math.round(i.price * 100) / 100
                  ]
                  volume.push [
                    Number(i.date) * 1000
                    Math.round(i.amount * 100) / 100
                  ]

                series[0].setData price
                series[1].setData volume

            do update
            setInterval ->
              update
            , 1 * 1 * 1000

      credits:
        enabled: false

      rangeSelector:
        inputEnabled: false
        selected: 0
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
          title:
            text: "Price"
          height: 160
          lineWidth: 2
        }
        {
          title:
            text: "Volume"
          top: 248
          height: 60
          offset: 0
          lineWidth: 2
        }
      ]

      series: [
        {
          type: "line"
          name: "BTC/CNY"
        }
        {
          type: "column"
          name: "Volume"
          yAxis: 1
        }
      ]

  @after 'initialize', ->
    @drawChart()
