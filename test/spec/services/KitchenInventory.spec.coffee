describe 'KitchenInventory Module', ->

  should = chai.should()
  authStub = window.authStub
  fbutilStub = window.fbutilStub
  flushAll = window.flushAll

  fbBase = 'KitchenInventory'
  $timeout = null
  beforeEach ->
    module 'KitchenInventory'
    module ($provide) -> window.provideAll($provide)
    inject (_$timeout_) -> $timeout = _$timeout_

  describe 'remoteInventory', ->
    fbPath = 'inStock'

    it 'should sync to to the correct firebase path when not authorized', ->
      inject (simpleLogin) -> authStub.$$isAuth = false
      inject (fbutil, remoteInventory) ->
        flushAll($timeout)
        fbutil.syncArray.should.be.calledWith "#{fbBase}/#{fbPath}"
        remoteInventory.ref().should.be.ok

    it 'should sync to the correct firebase path when authorized', ->
      inject (fbutil, remoteInventory) ->
        flushAll($timeout)
        fbutil.syncArray.should.be.calledWith "#{fbBase}/#{authStub.$$user.uid}/#{fbPath}"
        remoteInventory.ref().should.be.ok

    it 'should be watchable', ->
      inject (remoteInventory) ->
        spy = sinon.spy()
        remoteInventory.watch(spy)
        flushAll($timeout)
        spy.should.have.been.calledWith(authStub.$$user)

  describe 'inventoryNormalizer', ->
    fbPath = 'normalizer'

    it 'should sync to to the correct firebase path when not authorized', ->
      inject (simpleLogin) -> authStub.$$isAuth = false
      inject (fbutil, inventoryNormalizer) ->
        flushAll($timeout)
        fbutil.syncObject.should.be.calledWith "#{fbBase}/#{fbPath}"
        inventoryNormalizer.ref().should.be.ok

    it 'should sync to the correct firebase path when authorized', ->
      inject (fbutil, inventoryNormalizer) ->
        flushAll($timeout)
        fbutil.syncObject.should.be.calledWith "#{fbBase}/#{authStub.$$user.uid}/#{fbPath}"
        inventoryNormalizer.ref().should.be.ok

    it 'should normalize ingredient strings properly', ->
      inject (inventoryNormalizer) ->
        inventoryNormalizer.strNormalize(['a', 'b', 'c']).should.have.length(3)
        inventoryNormalizer.strNormalize(['a', 'A', 'c']).should.have.length(2)
        inventoryNormalizer.strNormalize('fOO').should.eql('foo')

  describe 'KitchenInventory', ->

    it 'should have default ingredients', inject (KitchenInventory) ->
      KitchenInventory.should.have.property('defaultStock').with.length(4)
      KitchenInventory.should.have.property('inStock').with.length(4)

    it 'should be able to search for similar ingredients in stock', ->
      inject (KitchenInventory) ->
        item = KitchenInventory.inStock[0]
        KitchenInventory.getSimilar(item).should.have.length(0)
        KitchenInventory.getSimilar(item.substr 0, item.length - 2)
          .should.have.length(1)
        KitchenInventory.getSimilar(item + 'a').should.have.length(1)

    it 'should be able to find equivalent items using remote datastore', ->
      inject (KitchenInventory) ->
        flushAll($timeout)
        ref = KitchenInventory.normalizer.ref()
        ref['butter'] = pos: ['margerine']
        ref['peanut'] = pos: ['almond']
        query = ['butter', 'peanut', 'notfound']
        KitchenInventory.getEquivalent([]).should.have.length(0)
        KitchenInventory.getEquivalent(query).should.have.length(5)

    it 'should be able to set (in)equivalent ingredients', ->
      inject (KitchenInventory) ->
        flushAll($timeout)
        KitchenInventory.setEql('2% milk', 'milk')
        KitchenInventory.setEql('butter', 'margerine', false)

        flushAll($timeout)

        normalizer = KitchenInventory.normalizer.ref()
        normalizer['milk'].should.deep.eql pos: ['2% milk']
        normalizer['butter'].should.deep.eql neg: ['margerine']

    it 'should remove ingredient in stock after setting equivalent with another', ->
      inject (KitchenInventory) ->
        flushAll($timeout)

        KitchenInventory.add('butter')
        KitchenInventory.add('milk')
        KitchenInventory.inStock.should.have.length(2)
        KitchenInventory.setEql('butter', 'milk')
        KitchenInventory.inStock.should.have.length(1)
        KitchenInventory.inStock[0].should.eql('butter')

    it 'should union equivalent ingredient sets', ->
      inject (KitchenInventory) ->
        flushAll($timeout)

        KitchenInventory.setEql('2% milk', 'milk')
        KitchenInventory.setEql('milk', 'butter')
        KitchenInventory.setEql('milk', 'butter')

        flushAll($timeout)

        normalizer = KitchenInventory.normalizer.ref()
        normalizer['milk']['pos'].should.have.length(2)

        # Even if the map doesn't union ingredient set, our equivalence set
        # logic should.
        normalizer['2% milk']['pos'].should.have.length(1)
        KitchenInventory.getEquivalent(['2% milk']).should.have.length(3)

    it 'should contain ingredient if ingredient has equivalent in stock', ->
      inject (KitchenInventory) ->
        origStock = KitchenInventory.inStock # Default stock before flush.
        item = origStock[0]
        newItem = item + 'new'

        flushAll($timeout) # Load KitchenInventory normalizer.
        KitchenInventory.setEql(item, newItem)

        flushAll($timeout)

        # Flushing the db will clear our inventory, so reset to the original.
        KitchenInventory.inStock = origStock
        KitchenInventory.contains(newItem).should.be.true

    it 'should add/remove/contain ingredients', ->
      inject (KitchenInventory) ->
        origNumIngredients = KitchenInventory.defaultStock.length

        KitchenInventory.inStock.should.have.length(origNumIngredients)
        KitchenInventory.add('new')
        KitchenInventory.inStock.should.have.length(origNumIngredients + 1)
        KitchenInventory.defaultStock.should.have.length(origNumIngredients)
        KitchenInventory.contains('NEW').should.be.true

        # Adding again should prevent duplicate.
        KitchenInventory.add('nEW')
        KitchenInventory.inStock.should.have.length(origNumIngredients + 1)

        KitchenInventory.remove('new')
        KitchenInventory.inStock.should.have.length(origNumIngredients)
        KitchenInventory.contains('New').should.be.false

        # Removing a missing element should be ok.
        KitchenInventory.remove('new')
        KitchenInventory.inStock.should.have.length(origNumIngredients)
