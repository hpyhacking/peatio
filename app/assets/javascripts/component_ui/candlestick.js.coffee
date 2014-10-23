@CandlestickUI = flight.component ->
  @drawChart = ->
    dataGrouping =
      focus: true
      units: [['minute', [1, 3, 5, 15, 30]], ['hour', [1]]]

    @$node.highcharts "StockChart",
      title:
        text: "Spot Trading for #{gon.market.base_unit.toUpperCase()}/#{gon.market.quote_unit.toUpperCase()}"
        align: 'right'
      chart:
        backgroundColor: 'rgba(0,0,0, 0.0)'
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
        footerFormat: '</div>'
        positioner: -> {x: 44, y: 16}

      plotOptions:
        candlestick:
          color: '#990f0f'
          upColor: '#000000'
          lineColor: '#cc1414'
          upLineColor: '#49c043'
          dataGrouping: dataGrouping
          tooltip:
            pointFormat:
              """
              <span class=t-title>#{gon.i18n.chart.open}: </span><span class=t-value>{point.open}</span>
              <span class=t-title>#{gon.i18n.chart.high}: </span><span class=t-value>{point.high}</span><br />
              <span class=t-title>#{gon.i18n.chart.close}: </span><span class=t-value>{point.close}</span>
              <span class=t-title>#{gon.i18n.chart.low}: </span><span class=t-value>{point.low}</span>
              """
        column:
          color: '#3e4c5a'
          dataGrouping: dataGrouping
          tooltip:
            pointFormat:
              """
              <span class=t-title>#{gon.i18n.chart.volume}: </span><span class=t-value>{point.y}</span>
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
        buttonTheme: { 
          fill: 'none',
          stroke: 'none',
          'stroke-width': 0,
          r: 8,
          style: {
            color: '#ccc',
            fontWeight: 'bold'
          },
          states: {
            hover: {
              fill: '#000',
            },
            select: {
              fill: '#000',
              style: {
                color: 'white'
              }
            }
          }
        },
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
          text: "1#{gon.i18n.time.hour}"
        ]

      xAxis:
        lineColor: '#333'
        tickColor: '#333'
        tickWidth: 2

      navigator:
        maskFill: 'rgba(32, 32, 32, 0.6)'
        outlineColor: '#333'
        outlineWidth: 1

      yAxis: [
        {
          opposite: false
          labels:
            enabled: true
          gridLineColor: '#222'
          gridLineDashStyle: 'ShortDot'
          top: "0%"
          height: "80%"
        }
        {
          opposite: false
          labels:
            enabled: false
          top: "80%"
          gridLineColor: '#000'
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
