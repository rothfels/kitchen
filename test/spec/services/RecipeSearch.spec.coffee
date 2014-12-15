describe 'RecipeSearch Module', ->
  should = chai.should()

  authStub = window.authStub
  fbutilStub = window.fbutilStub
  flushAll = window.flushAll

  $httpBackend = null
  beforeEach ->
    module 'RecipeSearch'
    module ($provide) -> window.provideAll($provide)
    inject (_$httpBackend_) -> $httpBackend = _$httpBackend_
    window.stubIndices($httpBackend)

  ingredients = mockIndices.mockIngredients

  it 'should have a default ingredient edit distance', ->
    inject (RecipeSearch) ->
      RecipeSearch.should.have.property('defaultEditDistance').that.equals(1)

  it 'should be able to run a recipe search with different edit distance', ->
    inject (RecipeSearch) ->
      # Correct the off by 1 on the forEach loop.
      # (The last recipe isn't referenced by any ingredients.)
      n = ingredients.length
      for i in [0...n-1]
        RecipeSearch.results(i, false).should.eventually.have.length(i + 1)

      RecipeSearch.results(n - 1, false).should.eventually.have.length(n - 1)
      $httpBackend.flush()

  it 'should be able to set ingredients and use the recipe search cache', ->
    inject (RecipeSearch) ->
      RecipeSearch.results(1).then (origSearchResults) ->
        RecipeSearch.setIngredients(ingredients.slice(0, 1))
        RecipeSearch.results(1, true)
          .should.eventually.have.length(origSearchResults.length)
        RecipeSearch.results(1, false)
          .should.eventually.not.have.length(origSearchResults.length)
      $httpBackend.flush()

  it 'should be able to return the search cache', inject (RecipeSearch) ->
    RecipeSearch.results(2).then (origSearchResults) ->
      RecipeSearch.searchCache().editDistance.should.equal(2)
      RecipeSearch.searchCache().recipeIdsPromise
        .should.eventually.have.length(origSearchResults.length)
    $httpBackend.flush()

  it 'should watch KitchenInventory', ->
    newItem = 'burrito'
    inject (fbutil) -> fbutilStub.init([newItem], 'KitchenInventory', 'inStock')
    inject (simpleLogin) -> authStub.$$isAuth = false
    inject (RecipeSearch, KitchenInventory, $timeout) ->
      flushAll($timeout)

      RecipeSearch.searchCache().ingredients.should.have.length(1)
      RecipeSearch.searchCache().ingredients[0].should.eql(newItem)

      nextItem = 'chalula'
      KitchenInventory.add(nextItem)

      RecipeSearch.searchCache().ingredients.should.have.length(2)
      RecipeSearch.searchCache().ingredients[1].should.eql(nextItem)

  it 'should run search with equivalent ingredients', ->
    inject (RecipeSearch, KitchenInventory, $timeout) ->
      flushAll($timeout)

      KitchenInventory.add('butter')
      RecipeSearch.searchCache().recipeIdsPromise.should.eventually.have.length(0)

      # Flush the indices before setting equality so that both async code blocks
      # don't execute after we call KitchenInventory.setEql
      $httpBackend.flush()
      KitchenInventory.setEql('butter', 'milk')

      RecipeSearch.results(null, false)
      RecipeSearch.searchCache().recipeIdsPromise.should.eventually.not.have.length(0)

      $timeout.flush() # The last async block still needs to be flushed.


  # it 'should return some results even if no ingredients are in stock', ->
  #   RecipeSearch.setIngredients([])
  #   RecipeSearch.results().should.eventually.not.have.length(0)
  #   $httpBackend.flush()
