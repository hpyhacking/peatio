Highcharts.setOptions
  global:
    useUTC: false

if gon.local is "zh-CN"
  Highcharts.setOptions
    lang:
      months: ['一月', '二月', '三月', '四月', '五月', '六月',  '七月', '八月', '九月', '十月', '十一月', '十二月']
      shortMonths: ['一月', '二月', '三月', '四月', '五月', '六月',  '七月', '八月', '九月', '十月', '十一月', '十二月']
      weekdays: ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']

render = Highcharts.RangeSelector.prototype.render

Highcharts.RangeSelector.prototype.render = (min, max) ->
    render.apply(this, [min, max])
    leftPosition = @.chart.plotLeft
    topPosition = @.chart.plotTop
    space = 10

    @.zoomText.attr
      x: leftPosition + 2,
      y: topPosition + 15,
      text: gon.i18n.chart.zoom

    leftPosition += @.zoomText.getBBox().width + 15

    for button in @.buttons
      button.attr
        x: leftPosition
        y: topPosition 
      leftPosition += button.width + space

f = (callback) -> return
Highcharts.wrap Highcharts.Tooltip.prototype, 'hide', f
