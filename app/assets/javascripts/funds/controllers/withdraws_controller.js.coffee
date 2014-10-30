app.controller 'WithdrawsController', ($scope, $stateParams, $http) ->
  @withdraw = {}
  $scope.currency = $stateParams.currency
  $scope.name = current_user.name
  $scope.fsources = FundSource.findAllBy('currency', $scope.currency)
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.balance = $scope.account.balance
  $scope.withdraw_channel = WithdrawChannel.findBy('currency', $scope.currency)

  @createWithdraw = (currency) ->
    ctrl = @
    withdraw_channel = WithdrawChannel.findBy('currency', currency)
    account = withdraw_channel.account()

    data = { withdraw: { member_id: current_user.id, currency: currency, sum: @withdraw.sum, fund_source: @withdraw.fund_source } }

    if current_user.app_activated or current_user.sms_activated
      type = $('.two_factor_auth_type').val()
      otp = $("#two_factor_otp").val()
      data['two_factor'] = { type: type, otp: otp }

    $('.form-submit > input').attr('disabled', 'disabled')

    $http.post("/withdraws/#{withdraw_channel.resources_name}", data)
      .error (response) ->
        $.publish 'flash', { message: response.responseText }
      .finally ->
        ctrl.withdraw = {}
        $('.form-submit > input').removeAttr('disabled')


  $scope.sms_and_app_activated = ->
    current_user.app_activated and current_user.sms_activated

  $scope.only_app_activated = ->
    current_user.app_activated and !current_user.sms_activated

  $scope.only_sms_activated = ->
    current_user.sms_activated and !current_user.app_activated

  $.publish "two_factor_init"
