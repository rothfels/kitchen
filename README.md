# Forward

I built this to play with Javascript (and eventually Coffeescript). I wanted to do this on a client because it was
unfamiliar. Testing felt quite different than what I'm used to (Java), though not so foreign coming recently from Scala.

There's a lot of room for improvement if I want to be critical:

In particular, test coverage isn't complete. Mostly due to laziness since I'm not trying to accomplish anything
with the project. The only reason the tests are in there in the first place is that I wanted to learn how to write them,
so I think they should just feel lucky.

There's also not a tremendous amount of stylistic consistency in the code, partly because I was playing with different
editors, linters, beautifiers, etc. while I was building this.

Some things will just look stupid because I wrote them earlier than others. The first javascript you write looks
pretty horrendous, even when you know it. I cleaned some gross things along the way; others have been left to rot.
Particularly the .js files. Most of the smarter things are in .coffee.

For my first Javascript maybe it's not too bad.

It's a coincidence it's about food.

# Summary

An angular project built up from auto-generated starter code (https://github.com/diegonetto/generator-ionic).

There's no particular reason it uses a mobile framework, though that part does provide some of the scaffolding.
Most it bundles angular-ui-router with a bunch of other javascript to handle routing / navigation through
the application. I have to declaratively specify which states are in the app and the ionic framework does the rest.
States point to templates which are filled by my controllers and services.
Oh yeah also the only reason the application looks reasonable at all is because of the ionic styling.
Beyond that, there's not much of it I'm using.

The application keeps track of a kitchen inventory and shows you recipes that your inventory can make (with allowance,
for example, "show me yummy things that I can make within 2 ingredients"). I don't care about the actual recipes, just
the pretty pictures. :)

Most of the logic is implemented in singleton objects (angular factories) found in app/scripts/services. These are:

  - KitchenAuth.coffee: an authentication module providing simpleLogin, to create accounts or authenticate returning users.

  - KitchenInventory.coffee: a module to manage a remote datastore containing the user's current ingredients.
    The KitchenInventory module is is also responsible for normalizing ingredients. Right now it "learns" to identify
    equivalent ingredients via direct input from the user (see "toasts"). This way, it's possible to find pictures
    of recipes with '2% milk' when you have 'milk'. Obviously this is a pretty stupid way to have the computer learn,
    but my intention wasn't to solve the problem intelligently just to have some fun writing toasts. If I wanted to do
    better, I could probably find this information already online somewhere, or just do a preprocessing step on the indices.

  - RecipeIndex.coffee: a module to load data about recipes (including ingredients required by the recipe).
    RecipeIndex right now loads static JSON included in the app/data directory. I got the data using
    some web scrapers I wouldn't be proud to show. I have about 50k recipes currently in the project of a total
    250k downloaded. While I haven't been trying to optimize the performance of the app, it seems to work okay right now for
    reasonably sized kitchen inventories (and not unreasonable search query parameters).

  - RecipeSearch.coffee: a module to identify recipes your ingredients can make.
    The RecipeSearch module has some simple optimizations, like a primitive cache, to help improve performance a little
    between page loads. It currently has KitchenInventory as a dependency in order to show default search results
    for the default KitchenInventory (before the remote datastore loads).

The interface is controlled by angular controllers found in app/scripts/controllers. These mostly delegate to the
services described above. In summary, they are responsible for:

  - adding / removing ingredients
  - changing recipe search parameters (such as ingredient "edit distance" from current in-stock set)
  - login / account creation
  - modifying user profile information
  - "toasts" (if the user adds an ingredient that looks similar to one already in stock, ask if it is the same or not)

The application is currently configured to have RecipeSearch re-run a new search automatically whenever the KitchenInventory
stock changes. This can happen when the remote's initial data loads, authentication status changes, or when the user
directly mutates KitchenInventory. You can image the relationship like this:

  RecipeSearch --watches--> KitchenInventory --watches--> KitchenAuth

There is a single "anonymous" remote identity shared by all non-authenticated applications. The app should theoretically
work just fine offline, though all the data will be volatile. It hasn't been tested at all for this.

There's other angular suspects you'll find in the main application directory somewhere (filters, decorators,
directives). Not much going on there. In routes.js I have some utilities to help deal with authentication
and redirect. The config.js file is autogenerated (to facilitate deployment to different production environments) from
the Grunt file.

I'm using Firebase as a remote datastore and with it a bundled authentication provider. The firebase interface supports
simple CRUD operations, and also provides useful utilities to bind remote object references to the current angular $scope.
I wrap the $firebase lib with app/scripts/util/firebase.utils.js. Both Firebase and its authentication module are stubbed
for unit testing. The app/scripts/database directory contains some helper modules for interacting with the database.

The HTML is hastily put together and soon forgotten. It deserves some TLC but I thought my time was better spent
learning some other things in here first.

# Tests

The test directory currently contains only unit tests and relies heavily on angular mocking libraries. There
are a good number of tests about asynchrony, data binding, and the general business logic of the application.
There's still room for improvement here and a lot of tests are missing. I think the tests describe themselves
reasonably well so you can check them out directly if you are curious what's been tested.

You'll find some fake data in test/mock/indices.js, and my mocking/stubbing utilities in test/mock/MockUtils.coffee.

# Workflow

grunt serve

grunt test

(et al, see https://github.com/diegonetto/generator-ionic)
