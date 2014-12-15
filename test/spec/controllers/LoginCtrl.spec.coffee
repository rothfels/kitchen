describe 'LoginCtrl', ->
  should = chai.should()

  $scope = null
  beforeEach ->
    module 'mock.firebase'
    module 'LoginCtrl'
    module ($provide) -> window.provideAll($provide)
    inject ($controller, $rootScope) ->
      $scope = $rootScope.$new()
      $controller 'LoginCtrl', $scope: $scope

  it 'should define login function', ->
    $scope.login.should.be.a('function')

  it 'should define createAccount function', ->
    $scope.createAccount.should.be.a('function')
