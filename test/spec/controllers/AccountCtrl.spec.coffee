describe 'AccountCtrl', ->
  should = chai.should()

  this.timeout 3000

  $scope = null
  beforeEach ->
    module 'mock.firebase'
    module 'AccountCtrl'
    module ($provide) ->
      window.requireUser($provide)
      window.provideAll($provide)
    inject ($controller, $rootScope) ->
      $scope = $rootScope.$new()
      $controller 'AccountCtrl', $scope: $scope

  it 'should define logout method', ->
    $scope.logout.should.be.a('function')

  it 'should define changePassword method', ->
    $scope.changePassword.should.be.a('function')

  it 'should define changeEmail method', ->
    $scope.changeEmail.should.be.a('function')

  it 'should define clear method', ->
    $scope.clear.should.be.a('function')
