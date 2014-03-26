@OrderEnterBidUI = flight.component ->
  flight.compose.mixin @, [OrderEnterMixin]

  @after 'initialize', ->
    @on document, 'order::plan', @orderPlan
    @on document, 'market::price::bid', @refreshPrice

    @on @select('formSel'), 'ajax:success', @handleSuccess
    @on @select('formSel'), 'ajax:error', @handleError

    @on @select('sumSel'), 'change paste keyup', @computeVolume
    @on @select('priceSel'), 'change paste keyup', @computeSum
    @on @select('volumeSel'), 'change paste keyup', @computeSum

    @on @select('priceSel'), 'focusout', @computeSum
    @on @select('volumeSel'), 'focusout', @computeSum
