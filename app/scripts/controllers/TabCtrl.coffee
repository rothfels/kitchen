angular.module 'TabCtrl', ['KitchenAuth']

.controller 'TabCtrl', ($scope, simpleLogin) ->
  $scope.auth = false
  simpleLogin.watch (user) ->
    $scope.auth = user?
  , $scope
