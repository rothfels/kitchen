angular.module 'Refs', ['firebase.utils']

.value 'inventoryBasePath', 'KitchenInventory'

.value 'tryAppendUID', (target, user) -> "#{target}#{if user? then "/#{user.uid}" else ''}"

.factory 'inStockPath', (inventoryBasePath, tryAppendUID) ->
  (user) -> "#{tryAppendUID(inventoryBasePath, user)}/inStock"

.factory 'normalizerPath', (inventoryBasePath, tryAppendUID) ->
  (user) -> "#{tryAppendUID(inventoryBasePath, user)}/normalizer"

.factory 'inStockRef', (inStockPath, fbutil) ->
  (user) -> fbutil.ref(inStockPath(user))

.factory 'normalizerRef', (normalizerPath, fbutil) ->
  (user) -> fbutil.ref(normalizerPath(user))
