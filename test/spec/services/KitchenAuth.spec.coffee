describe 'KitchenAuth Module', ->
  should = chai.should()
  expect = chai.expect

  authStub = window.authStub
  flushAll = window.flushAll

  $timeout = simpleLogin = null
  beforeEach ->
    MockFirebase.override()
    module 'KitchenAuth'
    module ($provide) -> window.provideAll($provide)
    inject (_$timeout_) -> $timeout = _$timeout_
    inject (_simpleLogin_) -> simpleLogin = _simpleLogin_

  afterEach ->
    window.Firebase = MockFirebase._origFirebase
    window.FirebaseSimpleLogin = MockFirebase._origFirebaseSimpleLogin

  describe 'requireUser', ->
    it 'should error if not authenticated', inject (requireUser) ->
      authStub.$$isAuth = false
      spy = sinon.spy()
      requireUser().catch(spy)
      flushAll($timeout)
      spy.should.have.been.calledWith(authRequired: true)

    it 'should succeed if authenticated', inject (requireUser) ->
      spy = sinon.spy()
      requireUser().then(spy)
      flushAll($timeout)
      spy.should.have.been.calledWith(authStub.$$user)

  describe 'simpleLogin', ->
    describe '#user', ->
      it 'should initialize with the current user when authenticated', ->
        expect(simpleLogin.user).to.eql(null)
        flushAll($timeout)
        simpleLogin.user.should.eql(authStub.$$user)

      it 'should initialize with the current user when not authenticated', ->
        # Since simpleLogin has already been injected with an authenticated
        # user, manually set authentication and trigger a refresh.
        authStub.$$isAuth = false
        inject ($rootScope) -> $rootScope.$broadcast(authStub.events.refresh)
        flushAll($timeout)
        expect(simpleLogin.user).to.eql(null)

      it 'should update when $firebaseSimpleLogin fails', ->
        flushAll($timeout) # Initialize user; see previous test.
        simpleLogin.user.should.not.eql(null)

        authStub.$$isAuth = false
        authStub.error('$login') # Any method will work.
        spy = sinon.spy()
        inject ($rootScope) -> $rootScope.$on(authStub.events.error, spy)

        # We should see simpleLogin.user set from the initial authentication,
        # and unset after any failure.
        simpleLogin.login('test@test.com', '123')
        flushAll($timeout)
        expect(simpleLogin.user).to.eql(null)
        spy.should.have.been.called

    describe '#getUser', ->
      it 'should be fulfilled correctly based on auth status', ->
        simpleLogin.getUser().should.become(authStub.$$user)
        flushAll($timeout)
        authStub.$$isAuth = false
        simpleLogin.getUser().should.become(null)
        flushAll($timeout)

    describe '#login', ->
      it 'should error if $firebaseSimpleLogin.$login fails', ->
        spy = sinon.spy()
        authStub.error(method = '$login')
        simpleLogin.login('test@test.com', '123').catch(spy)
        flushAll($timeout)
        spy.should.have.been.calledWith("#{method} err")

      it 'should resolve user if $firebaseSimpleLogin.$login succeeds', ->
        [spy1, spy2] = [sinon.spy(), sinon.spy()]
        inject ($rootScope) -> $rootScope.$on(authStub.events.$login, spy1)
        simpleLogin.login('test@test.com', '123').then(spy2)
        flushAll($timeout)
        spy1.should.have.been.called
        spy2.should.have.been.calledWith(authStub.$$user)

      it 'should populate the current user', ->
        flushAll($timeout)
        simpleLogin.user.should.eql(authStub.$$user)

        simpleLogin.user = null # Manually set for testing.
        expect(simpleLogin.user).to.eql(null)

        simpleLogin.login('test@test.com', '123')
        flushAll($timeout)
        simpleLogin.user.should.eql(authStub.$$user)

    describe '#logout', ->
      it 'should invoke $firebaseSimpleLogin.$logout()', ->
        spy = sinon.spy()
        inject ($rootScope) -> $rootScope.$on(authStub.events.$logout, spy)
        simpleLogin.logout()
        authStub.$$last.$logout.should.have.been.called

        flushAll($timeout)
        spy.should.have.been.called

      it 'should clear the current user', ->
        flushAll($timeout)
        simpleLogin.user.should.eql(authStub.$$user)

        simpleLogin.logout()
        flushAll($timeout)
        expect(simpleLogin.user).to.eql(null)

    describe '#changePassword', ->
      it 'should error if $firebaseSimpleLogin fails', ->
        spy = sinon.spy()
        authStub.error method = '$changePassword'
        simpleLogin.changePassword(oldpass: 124, newpass: 123, confirm: 123)
          .catch(spy)
        flushAll($timeout)
        spy.should.have.been.calledWith("#{method} err")
        authStub.$$last.$changePassword.should.have.been.called

      it 'should resolve user if $firebaseSimpleLogin succeeds', ->
        spy = sinon.spy()
        simpleLogin.changePassword(oldpass: 124, newpass: 123, confirm: 123)
          .then(spy)
        flushAll($timeout)
        spy.should.have.been.called
        authStub.$$last.$changePassword.should.have.been.called

    describe '#createAccount', ->
      it 'should invoke $firebaseSimpleLogin.$createUser', ->
        simpleLogin.createAccount('test@test.com', 123)
        authStub.$$last.$createUser.should.have.been.called

      it 'should error if $firebaseSimpleLogin fails', ->
        spy = sinon.spy()
        authStub.error(method = '$createUser')
        simpleLogin.createAccount('test@test.com', 123).catch(spy)
        flushAll($timeout)
        spy.should.have.been.calledWith("#{method} err")

      it 'should resolve user if $firebaseSimpleLogin succeeds', ->
        spy = sinon.spy()
        simpleLogin.createAccount('test@test.com', 123).then(spy)
        flushAll($timeout)
        spy.should.have.been.calledWith(authStub.$$user)

      it 'should login after $firebaseSimpleLogin succeeds', ->
        spy = sinon.spy()
        inject ($rootScope) -> $rootScope.$on(authStub.events.$login, spy)
        simpleLogin.createAccount('test@test.com', 123)
        flushAll($timeout)
        spy.should.have.been.called

    describe '#watch', ->
      it 'should invoke callback when user is first resolved', ->
        spy = sinon.spy()
        simpleLogin.watch(spy)
        flushAll($timeout)
        spy.should.have.been.calledWith(authStub.$$user)

      it 'should notify listeners of $firebaseSimpleLogin events', ->
        flushAll($timeout) # Clear queued events, e.g. statusChange()

        [spy1, spy2] = [sinon.spy(), sinon.spy()]
        simpleLogin.watch(spy1)
        simpleLogin.watch(spy2)
        inject ($rootScope) ->
          $rootScope.$broadcast(authStub.events.$login)
          $rootScope.$broadcast(authStub.events.$logout)
          $rootScope.$broadcast(authStub.events.error)

        flushAll($timeout)
        spy1.should.have.callCount(4)
        spy2.should.have.callCount(4)

      it 'should have an unbind handle', ->
        flushAll($timeout) # Clear queued events, e.g. statusChange()

        [spy1, spy2, spy3] = [sinon.spy(), sinon.spy(), sinon.spy()]
        simpleLogin.watch(spy1)
        unbind = simpleLogin.watch(spy2)
        simpleLogin.watch(spy3)

        unbind()
        inject ($rootScope) ->
          $rootScope.$broadcast(authStub.events.error)

        flushAll($timeout)
        spy1.should.be.calledTwice
        spy2.should.be.calledOnce
        spy3.should.be.calledTwice

      it 'should unbind a scope when the scope is destroyed', ->
        flushAll($timeout) # Clear queued events, e.g. statusChange()

        $scope = $rootScope = null
        inject (_$rootScope_) ->
          $rootScope = _$rootScope_
          $scope = $rootScope.$new()

        [spy1, spy2] = [sinon.spy(), sinon.spy()]
        simpleLogin.watch(spy1, $scope)
        simpleLogin.watch(spy2, $rootScope)
        $scope.$broadcast('$destroy')
        $rootScope.$broadcast(authStub.events.$login)

        flushAll($timeout)
        spy1.should.be.calledOnce
        spy2.should.be.calledTwice
