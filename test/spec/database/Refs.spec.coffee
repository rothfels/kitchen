describe 'Refs Module', ->
  expect = chai.expect

  beforeEach module 'Refs'

  user = window.authStub.$$user

  it 'should have the correct in-stock path',
  inject (inStockPath) ->
    expect(inStockPath(user)).to.eql("KitchenInventory/#{user.uid}/inStock")
    expect(inStockPath(null)).to.eql('KitchenInventory/inStock')

  it 'should have the correct normalizer path',
  inject (normalizerPath) ->
    expect(normalizerPath(user)).to.eql("KitchenInventory/#{user.uid}/normalizer")
    expect(normalizerPath(null)).to.eql('KitchenInventory/normalizer')
