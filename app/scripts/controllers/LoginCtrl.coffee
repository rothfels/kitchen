angular.module 'LoginCtrl', ['KitchenAuth', 'ionic']

.controller 'LoginCtrl', ($scope, $location, simpleLogin, $ionicViewService) ->
  $scope.createMode = false

  $scope.login = (email, pass) ->
    $scope.err = null
    simpleLogin.login(email, pass).then (user) ->
      $ionicViewService.nextViewOptions
        disableAnimate: true
        disableBack: true
      $location.path('/tab/account')
    , (err) ->
      $scope.err = errMessage(err)

  $scope.createAccount = (email, pass, passConfirm) ->
    $scope.err = null
    if assertValidAccountProps(email, pass, passConfirm)
      simpleLogin.createAccount(email, pass).then (user) ->
        $location.path('/tab/account')
      , (err) ->
        $scope.err = errMessage(err)

  assertValidAccountProps = (email, pass, passConfirm) ->
    if !email?
      $scope.err = 'Please enter an email address.'
    else if !pass? || !passConfirm?
      $scope.err = 'Please enter a password.'
    else if $scope.createMode && pass != passConfirm
      $scope.err = 'Passwords do not match.'

    !$scope.err?

  errMessage = (err) ->
    if angular.isObject(err) && err.code? then err.code else "#{err}"
