angular.module 'RecipeSearchCtrl', ['RecipeSearch']

.controller 'RecipeSearchCtrl', ($scope, RecipeSearch) ->
  # If given control group is the selected group, deselect it.
  # Else select the given control group.
  $scope.toggleGroup = (group) ->
    if $scope.isGroupShown group
      $scope.shownGroup = null
    else
      $scope.shownGroup = group

  $scope.isGroupShown = (group) -> $scope.shownGroup == group

  $scope.searchControlsVisible = false
  $scope.editDistance =
    (RecipeSearch.searchCache() && RecipeSearch.searchCache().editDistance) ||
    RecipeSearch.defaultEditDistance

  $scope.getResults = (editDistance, useCache) ->
    RecipeSearch.results(editDistance, useCache).then (recipes) ->
      $scope.recipes = recipes
      courses = recipe.attributes['course'] for recipe in recipes
      cuisines = recipe.attributes['cuisine'] for recipe in recipes
      $scope.groups =
        courses: _.compact _.uniq _.flatten courses
        cuisines: _.compact _.uniq _.flatten cuisines

  $scope.courseCategory = ''
  $scope.cuisineCategory = ''

  $scope.setCourse = (category) ->
    $scope.courseCategory = category

  $scope.setCuisine = (category) ->
    $scope.cuisineCategory = category

  $scope.getCategoryFilterLabel = (categoryLabel) ->
    if categoryLabel == 'Courses'
      _currentCategory = $scope.courseCategory
    else if categoryLabel == 'Cuisines'
      _currentCategory = $scope.cuisineCategory

    if _currentCategory.length == 0 then "All #{categoryLabel}"
    else _currentCategory

  $scope.getResults($scope.editDistance, true)
