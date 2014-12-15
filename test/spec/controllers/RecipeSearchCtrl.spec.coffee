describe 'RecipeSearchCtrl', ->
  should = chai.should()

  $scope = $httpBackend = null
  beforeEach ->
    module 'RecipeSearchCtrl'
    inject ($controller, $rootScope) ->
      $scope = $rootScope.$new()
      $controller 'RecipeSearchCtrl', $scope: $scope
    inject (_$httpBackend_) ->
      $httpBackend = _$httpBackend_
      window.stubIndices($httpBackend)

  it 'should have category filter groups attached to scope', ->
    $scope.getResults(1, false).then (results) ->
      $scope.should.have.property('recipes').that.is.ok
      $scope.groups.should.have.property('courses').with.length(2)
      $scope.groups.should.have.property('cuisines').with.length(1)

    $httpBackend.flush()

  it 'should be able to set category filters and modify label', ->
    $scope.courseCategory.should.equal('')
    $scope.cuisineCategory.should.equal('')
    $scope.getCategoryFilterLabel('Courses').should.equal('All Courses')
    $scope.getCategoryFilterLabel('Cuisines').should.equal('All Cuisines')
    $scope.setCourse('Desserts')
    $scope.setCuisine('Italian')
    $scope.getCategoryFilterLabel('Courses').should.equal('Desserts')
    $scope.getCategoryFilterLabel('Cuisines').should.equal('Italian')

  it 'should init w/ cached edit distance', inject ($controller, $rootScope) ->
    $scope.editDistance.should.equal(1)

    $scope.getResults(2, false).then (results) ->
      newScope = $rootScope.$new()
      $controller 'RecipeSearchCtrl', $scope: newScope

      newScope.editDistance.should.equal(2)

    $httpBackend.flush()

  it 'should have search controls not visible by default', ->
    $scope.searchControlsVisible.should.be.false

  it 'should be able to toggle between category filter groups', ->
    assertGroupShown = (group, bool) ->
      $scope.isGroupShown(group).should.equal(bool)

    assertGroupShown(1, false)
    assertGroupShown(2, false)

    $scope.toggleGroup(1)
    assertGroupShown(1, true)
    assertGroupShown(2, false)

    $scope.toggleGroup(2)
    assertGroupShown(1, false)
    assertGroupShown(2, true)

    $scope.toggleGroup(2)
    assertGroupShown(1, false)
    assertGroupShown(2, false)
