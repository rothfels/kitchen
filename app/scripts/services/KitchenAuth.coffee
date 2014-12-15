angular.module 'KitchenAuth', ['User', 'firebase', 'firebase.utils']

# A simple wrapper on simpleLogin.getUser() that returns a rejected promise
# if the user does not exists (i.e. makes 'user' required for angular resolve).
.factory 'requireUser', (simpleLogin, $q) ->
  -> simpleLogin.getUser().then (user) ->
    if user? then user
    else $q.reject authRequired: true

.factory 'simpleLogin',
($firebaseSimpleLogin, fbutil, createProfile, changeEmail, createKitchenInventory, $q, $rootScope) ->
  auth = $firebaseSimpleLogin(fbutil.ref()) # Init authentication on base path.
  listeners = []

  simpleLogin =
    user: null

    getUser: -> auth.$getCurrentUser()

    login: (email, pass) -> auth.$login 'password',
      email: email
      password: pass
      rememberMe: true

    logout: -> auth.$logout()

    createAccount: (email, pass, name) ->
      auth.$createUser(email, pass)
        .then ->
          # Authenticate so we have permission to write to Firebase.
          simpleLogin.login(email, pass)
        .then (user) ->
          # Store user data in Firebase after creating account.
          createProfile(user.uid, email, name).then -> user
        .then (user) ->
          createKitchenInventory(user.uid).then -> user

    changePassword: (email, oldpass, newpass) ->
      auth.$changePassword(email, oldpass, newpass)

    # Wrapper to inject this factory into changeEmail and avoid circular
    # dependency. The database/User module manages migration necessary for
    # email change.
    changeEmail: (password, newEmail) ->
      changeEmail(password, simpleLogin.user.email, newEmail, @)

    removeUser: (email, pass) -> auth.$removeUser(email, pass)

    watch: (cb, $scope) ->
      simpleLogin.getUser().then (user) -> cb(user)

      listeners.push(cb)
      unbind = ->
        i = listeners.indexOf(cb)
        listeners.splice(i, 1) if i > -1

      $scope.$on('$destroy', unbind) if $scope?
      unbind

  statusChange = ->
    simpleLogin.getUser().then (user) ->
      simpleLogin.user = user || null
      fn(simpleLogin.user) for fn in listeners

  $rootScope.$on '$firebaseSimpleLogin:login', statusChange
  $rootScope.$on '$firebaseSimpleLogin:logout', statusChange
  $rootScope.$on '$firebaseSimpleLogin:error', statusChange
  $rootScope.$on '$firebaseSimpleLogin:refresh', statusChange # For test / debug.
  statusChange()

  simpleLogin
