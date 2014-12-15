angular.module 'KitchenInventoryCtrl', ['KitchenInventory', 'RecipeIndex', 'ngMaterial']

.controller 'IngredientToastCtrl', ($scope, $mdToast, KitchenInventory) ->
  $scope.toast = KitchenInventory.getToast()

  $scope.submitResponse = (eql) ->
    KitchenInventory.setEql($scope.toast.item1, $scope.toast.item2, eql)
    KitchenInventory.releaseToast(true)
    $mdToast.hide()

  $scope.closeToast = -> $mdToast.hide()

.controller 'KitchenInventoryCtrl', ($scope, KitchenInventory, $mdToast, RecipeIndex, $timeout) ->
  $scope.ingredients = ($value: val for val in KitchenInventory.inStock)
  KitchenInventory.watch ->
      $scope.ingredients = KitchenInventory.ref()
  , $scope

  RecipeIndex.promise.then (indices) ->
    $scope.allIngredients = RecipeIndex.getIngredients(indices)

  $scope.addNewIngredient = (ingredient) ->
    KitchenInventory.add(ingredient)
    if KitchenInventory.tryLockToast()
      $mdToast.show
        controller: 'IngredientToastCtrl'
        templateUrl: 'templates/ingredient-toast.html'
        hideDelay: 6000
        position: 'bottom left'

  $scope.removeIngredient = (ingredient) ->
    KitchenInventory.remove(ingredient)
