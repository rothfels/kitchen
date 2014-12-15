describe 'User Module', ->
  should = chai.should()

  fbutilStub = window.fbutilStub
  flushAll = window.flushAll

  $timeout = null
  beforeEach ->
    module 'User'
    module ($provide) -> window.provideAll($provide)
    inject (_$timeout_) -> $timeout = _$timeout_

  describe '#createProfile', ->
    it 'should invoke set on Firebase', inject (createProfile) ->
      createProfile(123, 'test@test.com')
      flushAll($timeout)
      fbutilStub.$$last.ref.should.have.been.calledWith 'users', 123
      fbutilStub.$$lastRefs[0].set.should.have.been.calledWith
        email: 'test@test.com'
        name: 'Test'

    it 'should return a promise', inject (createProfile) ->
      spy = sinon.spy()
      createProfile(123, 'test@test.com').then(spy)
      flushAll($timeout)
      spy.should.have.been.calledWith(fbutilStub.$$lastRefs[0])

    it 'should return an error in the reject', inject (createProfile) ->
      fbutilStub.nextRefSetOverride = (val, cb) -> cb('fail') # Override to fail.

      spy = sinon.spy()
      createProfile(123, 'test@test.com').catch(spy)

      flushAll($timeout)
      spy.should.have.been.calledWith('fail')

  describe '#createKitchenInventory', ->
    it 'should invoke set on Firebase', inject (createKitchenInventory) ->
      createKitchenInventory(123)
      flushAll($timeout)
      fbutilStub.$$last.ref.should.have.been.calledWith('KitchenInventory', 123, 'inStock')
      fbutilStub.$$lastRefs[0].set.should.have.been.calledWith(['butter', 'milk'])


    it 'should return a promise', inject (createKitchenInventory) ->
      spy = sinon.spy()
      createKitchenInventory(123).then(spy)
      flushAll($timeout)
      spy.should.have.been.calledWith(fbutilStub.$$lastRefs[0])


    it 'should return an error in the reject', inject (createKitchenInventory) ->
      fbutilStub.nextRefSetOverride = (val, cb) -> cb('fail') # Override to fail.

      spy = sinon.spy()
      createKitchenInventory(123).catch(spy)
      flushAll($timeout)
      spy.should.have.been.calledWith('fail')
