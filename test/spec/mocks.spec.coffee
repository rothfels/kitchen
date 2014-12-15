describe 'Mocks', ->
  should = chai.should()

  ingredients = mockIndices.mockIngredients

  it 'should have the correct ingredient index mock', ->
    ingredientIndex = mockIndices.mockIngredientIndex()
    for i in [0...ingredients.length]
      ingredientIndex.should.have.property(ingredients[i]).with.length(i)

  it 'should have the correct recipe index mock', ->
    recipeIndex = mockIndices.mockRecipeIndex()
    for i in [0...ingredients.length]
      recipeIndex[i].should.have.property('ingredients').with.length(2 * i + 1)
