describe 'RecipeDetailCtrl Module', ->
  should = chai.should()

  $scope = $httpBackend = null
  beforeEach ->
    module 'mock.firebase'
    module 'RecipeDetailCtrl'
    module ($provide) -> window.provideAll($provide)
    inject ($controller, $rootScope) ->
      $scope = $rootScope.$new()
      $controller 'RecipeDetailCtrl',
        $scope: $scope
        $stateParams:
          recipeId: 1
    inject (_$httpBackend_) ->
      $httpBackend = _$httpBackend_
      window.stubIndices($httpBackend)

  it 'should attach a recipe to the scope', ->
    $scope.loadRecipe().then (recipe) ->
      $scope.recipe.should.be.ok

    $httpBackend.flush()

  it 'should allow the user to add / remove / toggle recipe ingredients',
  inject (KitchenInventory) ->
    $httpBackend.flush()

    ingredient = KitchenInventory.inStock[0]
    KitchenInventory.contains(ingredient).should.be.true
    $scope.removeIngredient(ingredient)
    KitchenInventory.contains(ingredient).should.be.false
    $scope.addIngredient(ingredient)
    KitchenInventory.contains(ingredient).should.be.true
    $scope.toggleIngredient(ingredient)
    KitchenInventory.contains(ingredient).should.be.false
    $scope.toggleIngredient(ingredient)
    KitchenInventory.contains(ingredient).should.be.true
