class KitchenInventory
  constructor: (@remote, @normalizer, @timeout) ->
    self = @
    @watch = @remote.watch
    @ref = @remote.ref
    @watch ->
      self.ref().$loaded().then (ingredients) ->
        self.inStock = _.compact (ingredient.$value for ingredient in ingredients)

  defaultStock = ['butter', 'milk', 'eggs', 'water']
  toastLock = null
  toasts = []

  defaultStock: defaultStock
  inStock: defaultStock.slice(0) # Create a copy.

  add: (ingredient) ->
    ingredient = @normalizer.normalize(ingredient)
    if ingredient.length > 0 and !@contains(ingredient)
      similar =  @getSimilar(ingredient)
      if similar.length > 0
        toasts.push
          item1: ingredient
          item2: similar[0]

      @inStock.push(ingredient)
      @ref()?.$add(ingredient)

  remove: (ingredient) ->
    if !_.isString(ingredient)
      ingredient = ingredient.$value

    ingredient = @normalizer.strNormalize(ingredient)
    if @contains(ingredient)
      index = _.indexOf(@inStock, ingredient)
      this.inStock = _.difference(@inStock, [ingredient])
      @ref()?.$remove(index)

  contains: (ingredient) ->
    ingredient = @normalizer.strNormalize(ingredient)
    filter1 = ($ for $ in @inStock when $ == ingredient)
    filter2 = ($ for $ in @getEquivalent(@inStock) when $ == ingredient)
    filter1.length > 0 || filter2.length > 0

  tryLockToast: ->
    if toastLock? || toasts.length == 0
      return false
    toastLock = {}
    true

  getToast: -> toasts[0]

  releaseToast: (ack) ->
    toasts.splice(0, 1) if ack?
    toastLock = null

  setEql: (ingredient1, ingredient2, eql = true) ->
    self = @
    ingredient1 = @normalizer.strNormalize(ingredient1)
    ingredient2 = @normalizer.strNormalize(ingredient2)
    @normalizer.ref().$loaded().then (data) ->

      data[ingredient1] = {} if not data[ingredient1]?
      data[ingredient2] = {} if not data[ingredient2]?

      label = if eql then 'pos' else 'neg'
      data[ingredient1][label] =
        _.union(data[ingredient1][label] || [], [ingredient2])
      data[ingredient2][label] =
        _.union(data[ingredient2][label] || [], [ingredient1])

      self.normalizer.ref().$save()

    @remove(ingredient2) if eql and
      _.contains(@inStock, ingredient1) and
      _.contains(@inStock, ingredient2)

  getEquivalent: (ingredients) -> @normalizer.findEquivalent(ingredients)
    # ingredients = @normalizer.strNormalize(ingredients)
    # res = (@normalizer.ref()?[ingredient]?['pos'] for ingredient in ingredients)
    # _.reduce _.compact(res), ((sum, arr) -> sum.concat(arr)), [] # Flatten.

  getSimilar: (ingredient) ->
    ingredient = @normalizer.strNormalize(ingredient)
    isSimilar = (item1, item2) ->
      item1.indexOf(item2) > -1 || item2.indexOf(item1) > -1
    similar = (item for item in @inStock when isSimilar(item, ingredient))
    _.difference similar, @getEquivalent([ingredient])


angular.module 'KitchenInventory', ['firebase.utils', 'KitchenAuth', 'Refs']

.factory 'ingredientNormalizer', ->
  (ingredients) ->
    if _.isString ingredients
      # Assume the caller wants to normalize a single ingredient.
      return ingredients.toLowerCase()

    # Unique values, all lower case.
    _.uniq (ingredient.toLowerCase() for ingredient in ingredients)

.factory 'remoteInventory', (fbutil, simpleLogin, inStockPath) ->
  remote = null
  remoteSync = (user) ->
    path = inStockPath(user)
    remote?.$destroy()
    remote = fbutil.syncArray(path)

  simpleLogin.watch remoteSync

  ref: -> remote
  watch: simpleLogin.watch

.factory 'inventoryNormalizer', (fbutil, simpleLogin, normalizerPath) ->
  ref = null
  remoteSync = (user) ->
    path = normalizerPath(user)
    ref?.$destroy()
    ref = fbutil.syncObject(path)

  simpleLogin.watch remoteSync

  findEquivalent: (ingredients) ->
    ingredients = @strNormalize(ingredients)
    res = (ref?[ingredient]?['pos'] for ingredient in ingredients)
    res = _.reduce _.compact(res), ((sum, arr) -> sum.concat(arr)), [] # Flatten
    res = _.uniq res

    # Now recursively explode the equivalence set to fill missing values until
    # all equivalences are known.
    memo = _.zipObject(res, true)
    explode = (item) ->
      addlVals = ref?[item]?['pos']
      if addlVals?
        for val in addlVals
          if !memo[val]?
            res.push('' + val) # Push copy.
            memo[val] = true
            explode(val)

    explode(item) for item in res
    _.uniq res.concat(ingredients) # All ingredients are equivalents of self.

  ref: -> ref
  normalize: (ingredients) -> @strNormalize(ingredients)
  strNormalize: (ingredients) ->
    if _.isString ingredients
      # Assume the caller wants to normalize a single ingredient.
      return ingredients.toLowerCase()

    # Unique values, all lower case.
    _.uniq (ingredient.toLowerCase() for ingredient in ingredients)

.factory 'KitchenInventory', (remoteInventory, inventoryNormalizer, $timeout) ->
  new KitchenInventory(remoteInventory, inventoryNormalizer, $timeout)
