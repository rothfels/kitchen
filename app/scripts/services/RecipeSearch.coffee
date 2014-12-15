angular.module 'RecipeSearch', ['RecipeIndex', 'KitchenInventory']

.factory 'RecipeSearch',
(ingredientNormalizer, KitchenInventory, RecipeIndex) ->
  ingredients = KitchenInventory.inStock
  KitchenInventory.watch ->
    refresh = ->
      ingredients = KitchenInventory.inStock
      search()

    KitchenInventory.ref().$loaded().then(refresh)
    KitchenInventory.ref().$watch(refresh)

  _searchCache = _indices = null
  search = (editDistance) ->
    editDistance = 1 if not editDistance?

    recipeIdsPromise = RecipeIndex.promise.then (indices) ->
      _indices = indices

      allIngredients =
        ingredients.concat KitchenInventory.normalizer.findEquivalent(ingredients)
      allIngredients = _.uniq allIngredients

      # Find all recipes matched for each ingredient in stock.
      allRecipes =
        (indices.ingredientIndex[ingredient] for ingredient in allIngredients)

      # Remove undefined values.
      allRecipes = _.compact(allRecipes)

      # Flatten array of arrays.
      allRecipes = _.reduce allRecipes, (sum, arr) -> sum.concat(arr)

      # Uniq.
      allRecipes = _.uniq(allRecipes)

      # Filter down to recipes that only use our ingredients,
      # within edit distance.
      recipeFilter = _.filter allRecipes, (recipeID) ->
        recipeIngredients =
          ingredientNormalizer(_indices.recipeIndex[recipeID].ingredients)
        _.difference(recipeIngredients, allIngredients).length <= editDistance

    result =
      ingredients: ingredients,
      editDistance: editDistance,
      recipeIdsPromise: recipeIdsPromise

    _searchCache = result
    _searchCache

  defaultEditDistance: 1
  setIngredients: (_ingredients) ->
    ingredients = _ingredients
  searchCache: -> _searchCache
  results: (editDistance, useCache = true) ->
    if useCache
      promise = (_searchCache || search(editDistance)).recipeIdsPromise
    else
      promise = search(editDistance).recipeIdsPromise

    promise.then (recipeIds) ->
      RecipeIndex.reverseLookup(recipeIds, _indices.recipeIndex)
