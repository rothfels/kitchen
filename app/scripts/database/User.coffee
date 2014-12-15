angular.module 'User', ['firebase.utils']

.factory 'createProfile', ($q, $timeout, fbutil) ->
  (id, email, name) ->
    firstPartOfEmail = (email) ->
      ucfirst email.substr(0, email.indexOf('@'))

    ucfirst = (str) -> "#{str.charAt(0).toUpperCase()}#{str.substr(1)}"

    ref = fbutil.ref('users', id)
    def = $q.defer()
    ref.set
      email: email
      name: if name? then name else firstPartOfEmail(email)
    , (err) ->
      if err? then def.reject(err)
      else def.resolve(ref)

    def.promise

.factory 'createKitchenInventory', ($q, $timeout, fbutil) ->
  (id) ->
    ref = fbutil.ref('KitchenInventory', id, 'inStock')
    def = $q.defer()
    ref.set ['butter', 'milk'], (err) ->
      if err? then def.reject(err)
      else def.resolve(ref)

    def.promise

.factory 'changeEmail', ($q, fbutil) ->
  # Inject simpleLogin to prevent circular dependency.
  # In order to change email, we have to destroy / create accounts.
  (password, oldEmail, newEmail, simpleLogin) ->
    ctx =
      old:
        email: oldEmail
      curr:
        email: newEmail

    authOldAccount = ->
      simpleLogin.login(ctx.old.email, password).then (user) ->
        ctx.old.uid = user.uid

    loadOldProfile = ->
      def = $q.defer()
      ctx.old.ref = fbutil.ref('users', ctx.old.uid)

      ctx.old.ref.once 'value', (snap) ->
        data = snap.val()
        if !data? then def.reject("#{oldEmail} not found.")
        else
          ctx.old.name = data.name
          def.resolve()
      , (err) -> def.reject(err)

      def.promise

    createNewAccount = ->
      simpleLogin.createAccount(ctx.curr.email, password, ctx.old.name)
        .then (user) -> ctx.curr.uid = user.uid

    copyProfile = ->
      def = $q.defer()
      ctx.curr.ref = fbutil.ref('users', ctx.curr.uid)

      profile =
        email: ctx.curr.email
        name: ctx.old.name || ''
      ctx.curr.ref.set profile, (err) ->
        if err?
          def.reject(err)
        else
          def.resolve()

      def.promise

    removeOldProfile = ->
      def = $q.defer()
      ctx.old.ref.remove (err) ->
        if err?
          def.reject(err)
        else
          def.resolve()

      def.promise

    removeOldLogin = ->
      def = $q.defer()
      simpleLogin.removeUser(ctx.old.email, password).then ->
        def.resolve()
      , (err) -> def.reject(err)

      def.promise

    authNewAccount = -> simpleLogin.login(ctx.curr.email, password)

    # Execute activities in order; first we authenticate the user.
    authOldAccount()
    # Then we fetch old account details.
    .then(loadOldProfile)
    # Then we create a new account.
    .then(createNewAccount)
    # Then we copy old account info,
    .then(copyProfile)
    # Once they safely exist, then we can delete the old profile.
    # We have to authenticate as the old user again to do so.
    .then(authOldAccount)
    .then(removeOldProfile)
    .then(removeOldLogin)
    # And now authenticate as the new user.
    .then(authNewAccount)
    .catch (err) -> $q.reject(err)
