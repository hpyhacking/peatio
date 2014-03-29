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
              $.getJSON "/api/prices/#{gon.market.id}", (data) ->
                price  = []
                volume = []

                for i in data
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

            update()
            setInterval ->
              update
            , 5 * 60 * 1000

      navigator:
        top: 300

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
            text: gon.i18n.chart_price
          height: 160
          lineWidth: 2
        }
        {
          title:
            text: gon.i18n.chart_volume
          top: 200
          height: 60
          offset: 0
          lineWidth: 2
        }
      ]

      series: [
        {
          type: "line"
          name: gon.i18n.chart_price
        }
        {
          type: "column"
          name: gon.i18n.chart_volume
          yAxis: 1
        }
      ]

  @after 'initialize', ->
    @drawChart()
