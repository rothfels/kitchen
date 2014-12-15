angular.module 'AccountCtrl', ['ionic', 'KitchenAuth', 'firebase.utils']

.controller 'AccountCtrl',
($scope, simpleLogin, fbutil, user, $location, $ionicViewService) ->
  # Create a 3-way binding with the user profile object in Firebase.
  profile = fbutil.syncObject(['users', user.uid])
  profile.$bindTo($scope, 'profile')

  $scope.userId = user.uid
  $scope.showChangePassword = false
  $scope.showChangeEmail = false

  resetMessages = ->
    $scope.err = null
    $scope.msg = null
    $scope.emailerr = null
    $scope.emailmsg = null

  $scope.logout = ->
    profile.$destroy()
    simpleLogin.logout()
    $ionicViewService.nextViewOptions
      disableAnimate: true
      disableBack: true
    $location.path('/tab/login')

  $scope.changePassword = (pass, confirm, newPass) ->
    resetMessages()
    if !pass? || !confirm? || !newPass?
      $scope.err = 'Please fill in all password fields.'
    else if newPass != confirm
      $scope.err = 'New pass and confirm do not match.'
    else
      simpleLogin.changePassword(profile.email, pass, newPass).then ->
        $scope.msg = 'Password changed.'
      , (err) ->
        $scope.err = err

  $scope.clear = resetMessages

  $scope.changeEmail = (pass, newEmail) ->
    resetMessages()
    profile.$destroy()
    simpleLogin.changeEmail(pass, newEmail).then (user) ->
      profile = fbutil.syncObject(['users', user.uid])
      profile.$bindTo($scope, 'profile')
      $scope.emailmsg = 'Email changed.'
    , (err) ->
      $scope.emailerr = err
