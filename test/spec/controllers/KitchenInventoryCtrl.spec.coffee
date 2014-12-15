describe 'KitchenInventoryCtrl', ->
  expect = chai.expect

  authStub = window.authStub
  fbutilStub = window.fbutilStub
  flushAll = window.flushAll

  beforeEach ->
    module 'KitchenInventoryCtrl'
    module ($provide) -> window.provideAll($provide)

  it 'should attach default in-stock ingredients to the scope before firebase is connected',
  inject ($controller, $rootScope) ->
    $controller 'KitchenInventoryCtrl', $scope: $rootScope
    expect($rootScope.ingredients).to.have.length(4)

  it 'should attach all known ingredients to the scope once RecipeIndex loads',
  inject ($httpBackend, $controller, $rootScope) ->
    window.stubIndices($httpBackend)
    $controller 'KitchenInventoryCtrl', $scope: $rootScope
    $httpBackend.flush()
    expect($rootScope.allIngredients).to.have.length(mockIndices.mockIngredients.length)

  it 'should watch KitchenInventory and attach remote in-stock ingredients to the scope once loaded',
  inject ($httpBackend, $controller, $rootScope, inStockPath, $timeout, fbutil) ->
    fbutilStub.init(['one', 'two'], inStockPath(authStub.$$user))
    window.stubIndices($httpBackend) # So RecipeIndex can load.

    $controller 'KitchenInventoryCtrl', $scope: $rootScope

    flushAll($timeout)
    expect($rootScope.ingredients).to.have.length(2)

    $rootScope.addNewIngredient('three')
    expect($rootScope.ingredients).to.have.length(2)
    flushAll($timeout) # Since ingredients is bound to remote, async operations must be flushed to be seen.
    expect($rootScope.ingredients).to.have.length(3)

    $rootScope.removeIngredient('four')
    expect($rootScope.ingredients).to.have.length(3)
    flushAll($timeout)
    expect($rootScope.ingredients).to.have.length(3)

    $rootScope.removeIngredient('three')
    expect($rootScope.ingredients).to.have.length(3)
    flushAll($timeout)
    expect($rootScope.ingredients).to.have.length(2)
