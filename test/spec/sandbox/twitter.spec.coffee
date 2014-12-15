describe 'Twitter Problem', ->
  expect = chai.expect

  # Returns a promise of an array of integers.
  # All failures are silently ignored.
  getTwitterFollowers = ($http, id) ->
    $http.get("twitter/#{id}").then (result) -> result.data

  numConnections = ($http, $q, rootID, degree = 1) ->
    visited = [] # All ids within degree, populated asynchronously.
    asyncChildren = 0 # Incremented when a new async "process" (i.e. explode, see below) is created.
    deferred = $q.defer() # Resolved when all async processes have completed; visited will be finished populating.

    completeAsyncChild = ->
      asyncChildren -= 1
      deferred.resolve(visited.length) if asyncChildren == 0

    explode = (id, currDegree) ->
      asyncChildren += 1

      if currDegree > 0
        getTwitterFollowers($http, id).then (arr) ->
          for connection in arr when connection != rootID && !_.contains(visited, connection)
            visited.push(connection)
            explode(connection, currDegree - 1)
          completeAsyncChild()
      else completeAsyncChild() # No async to do.

    explode(rootID, degree)
    deferred.promise

  it 'should work correctly for empty case (degree 0)',
  inject ($http, $q, $timeout) -> # No backend necessary since we will never call getTwitterFollowers.
    expect(numConnections($http, $q, 1, 0)).to.eventually.eql(0)
    $timeout.flush()

  it 'should work correctly if the root has no connections',
  inject ($http, $httpBackend, $q) ->
    $httpBackend.whenGET('twitter/1').respond([])
    expect(numConnections($http, $q, 1, degree)).to.eventually.eql(0) for degree in [1..3]
    $httpBackend.flush()

  it 'should work correctly for an directed cyclic graph',
  inject ($http, $httpBackend, $q) ->
    # 1 -> 2 -> 3 -> 4 -> 1
    $httpBackend.whenGET('twitter/1').respond([2])
    $httpBackend.whenGET('twitter/2').respond([3])
    $httpBackend.whenGET('twitter/3').respond([4])
    $httpBackend.whenGET('twitter/4').respond([1])

    expect(numConnections($http, $q, 1, 0)).to.eventually.eql(0)
    expect(numConnections($http, $q, 1, 1)).to.eventually.eql(1)
    expect(numConnections($http, $q, 1, 2)).to.eventually.eql(2)
    expect(numConnections($http, $q, 1, 3)).to.eventually.eql(3)
    expect(numConnections($http, $q, 1, 4)).to.eventually.eql(3)

    $httpBackend.flush()

  it 'should work correctly for an undirected cyclic graph',
  inject ($http, $httpBackend, $q) ->
    # 1 <-> 2 <-> 3 <-> 4 <-> 1
    $httpBackend.whenGET('twitter/1').respond([4, 2])
    $httpBackend.whenGET('twitter/2').respond([1, 3])
    $httpBackend.whenGET('twitter/3').respond([2, 4])
    $httpBackend.whenGET('twitter/4').respond([3, 1])

    expect(numConnections($http, $q, 1, 0)).to.eventually.eql(0)
    expect(numConnections($http, $q, 1, 1)).to.eventually.eql(2)
    expect(numConnections($http, $q, 1, 2)).to.eventually.eql(3)
    expect(numConnections($http, $q, 1, 3)).to.eventually.eql(3)

    $httpBackend.flush()
