angular.module 'RecipeIndex', ['ngResource', 'KitchenInventory']

.factory 'RecipeIndex', ($resource, $q, KitchenInventory) ->
  promise = $q.all
    recipeIndex: $resource('data/recipeIndex.json').get().$promise,
    ingredientIndex: $resource('data/ingredientIndex.json').get().$promise

  reverseLookup = (recipeIds, recipeIndex) ->
    fillProperties = (recipe) ->
      _.assign recipe,
        getRatingForCollectionRepeat: -> _.range(recipe.rating)
        ingredientsMissing:
          _.difference(recipe.ingredients, KitchenInventory.inStock)
        link: 'http://www.yummly.com/recipe/external/' + recipe.id

    fillProperties(recipeIndex[id]) for id in recipeIds

  getIngredients = (indices) ->
    res = (key for own key, value of indices.ingredientIndex)
    _.difference(res, ['$promise', '$resolved'])

  promise: promise
  reverseLookup: reverseLookup
  getIngredients: getIngredients
