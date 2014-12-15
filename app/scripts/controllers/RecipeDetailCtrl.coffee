angular.module 'RecipeDetailCtrl', ['RecipeSearch', 'KitchenInventory']

.controller 'RecipeDetailCtrl',
($scope, $stateParams, RecipeIndex, RecipeSearch, KitchenInventory) ->
  getIngredientsToggleMap = ->
    ingredientToggleObj = (ingredient) ->
      name: ingredient,
      checked: KitchenInventory.contains(ingredient)

    ingredientsToggleList =
      (ingredientToggleObj(ing) for ing in $scope.recipe.ingredients)

    _.zipObject($scope.recipe.ingredients, ingredientsToggleList)

  $scope.loadRecipe = ->
    RecipeIndex.promise.then (indices) ->
      $scope.recipe = indices.recipeIndex[$stateParams.recipeId]
      $scope.ingredientsToggleMap = getIngredientsToggleMap()
      $scope.recipe;

  $scope.addIngredient = (ingredient) ->
    KitchenInventory.add(ingredient)
    $scope.ingredientsToggleMap[ingredient].checked = true

  $scope.removeIngredient = (ingredient) ->
    KitchenInventory.remove(ingredient)
    $scope.ingredientsToggleMap[ingredient].checked = false

  $scope.toggleIngredient = (ingredient) ->
    if KitchenInventory.contains ingredient
      $scope.removeIngredient(ingredient)
    else
      $scope.addIngredient(ingredient)

  $scope.loadRecipe()
