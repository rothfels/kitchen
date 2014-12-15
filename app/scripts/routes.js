'use strict';

angular.module('Kitchen.routes', ['ionic', 'KitchenAuth', 'Kitchen.config'])

.constant('STATES', {
    'tab': {
        url: '/tab',
        abstract: true,
        templateUrl: 'templates/menu.html',
        controller: 'TabCtrl'
    },
    'tab.recipes': {
        url: '/recipes',
        views: {
            'menuContent': {
                templateUrl: 'templates/tab-recipes.html',
                controller: 'RecipeSearchCtrl'
            }
        }
    },
    'tab.recipe-detail': {
        url: '/recipes/recipe/:recipeId',
        views: {
            'menuContent': {
                templateUrl: 'templates/recipe-detail.html',
                controller: 'RecipeDetailCtrl'
            }
        }
    },
    'tab.kitchen': {
        url: '/kitchen',
        views: {
            'menuContent': {
                templateUrl: 'templates/tab-kitchen.html',
                controller: 'KitchenInventoryCtrl'
            }
        }
    },
    'tab.login': {
        url: '/login',
        views: {
            'menuContent': {
                templateUrl: 'templates/tab-login.html',
                controller: 'LoginCtrl'
            }
        }
    },
    'tab.account': {
        url: '/account',
        views: {
            'menuContent': {
                templateUrl: 'templates/tab-account.html',
                controller: 'AccountCtrl'
            }
        },
        authRequired: true
    }
})

/**
 * Adds a special `stateWhenAuthenticated` method onto $stateProvider. This special method,
 * when called, invokes the requireUser() service (see KitchenAuth.coffee).
 *
 * The promise either resolves to the authenticated user object and makes it available to
 * dependency injection or rejects the promise if user is not logged in,
 * forcing a redirect to the /login page.
 */
.config(['$stateProvider',
    function($stateProvider) {
        // Credits for this idea: https://groups.google.com/forum/#!msg/angular/dPr9BpIZID0/MgWVluo_Tg8J
        // Unfortunately, a decorator cannot be use here because they are not applied until after
        // the .config calls resolve, so they can't be used during state configuration, so we have
        // to hack it directly onto the $stateProvider object.
        $stateProvider.stateWhenAuthenticated = function(name, state) {
            state.resolve = state.resolve || {};
            state.resolve.user = ['requireUser', function(requireUser) {
                return requireUser();
            }];
            $stateProvider.state(name, state);
        };
    }
])

// Configure views; the authRequired parameter is used for specifying pages
// which should only be available while logged in.
.config(['$stateProvider', '$urlRouterProvider', 'STATES',
    function($stateProvider, $urlRouterProvider, STATES) {
    	_.forEach(_.keys(STATES), function(name) {
    		var state = STATES[name];
    		if (state.authRequired) {
    			// Adds a {resolve: user: {...}} promise which is rejected if
    			// the user is not authenticated or fulfills with the user object
    			// on success (the user object is then available to dependency injection).
    			$stateProvider.stateWhenAuthenticated(name, state);
    		} else {
    			// All other states are added normally.
    			$stateProvider.state(name, state);
    		}
    	});

      $urlRouterProvider.otherwise('/tab/kitchen'); // Catch exceptions.
    }
])

/**
 * Apply some route security. Any route's resolve method can reject the promise with
 * { authRequired: true } to force a redirect. This method enforces that and also watches
 * for changes in auth status which might require us to navigate away from a path
 * that we can no longer view.
 */
.run(['$rootScope', '$state', 'simpleLogin', 'STATES', 'loginRedirectState',
    function($rootScope, $state, simpleLogin, STATES, loginRedirectState) {
        // watch for login status changes and redirect if appropriate
        simpleLogin.watch(check, $rootScope);

        // some of our routes may reject resolve promises with the special {authRequired: true} error
        // this redirects to the login page whenever that is encountered
        $rootScope.$on('$stateChangeError', function(event, toState, toParams, fromState, fromParams, err) {
            if (_.isObject(err) && err.authRequired) {
                $state.go(loginRedirectState);
            }
        });

        function check(user) {
            if (!user && authRequired($state.current.name)) {
                $state.go(loginRedirectState);
            }
        }

        function authRequired(stateName) {
            return STATES.hasOwnProperty(stateName) && STATES[stateName].authRequired;
        }
    }
]);
