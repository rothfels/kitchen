'use strict';

/**
 * Wraps ng-cloak so that, instead of simply waiting for Angular to compile, it waits until
 * simpleLogin resolves with the remote Firebase services.
 */
angular.module('Kitchen.decorators', ['firebase.utils', 'KitchenAuth'])

.config(['$provide', function($provide) {
    // Adapt ng-cloak to wait for auth before it does its magic.
    $provide.decorator('ngCloakDirective', ['$delegate', 'simpleLogin',
        function($delegate, simpleLogin) {
            var directive = $delegate[0];
            // Make a copy of the old directive.
            var _compile = directive.compile;
            directive.compile = function(element, attr) {
                simpleLogin.getUser().then(function() {
                    // After auth, run the original ng-cloak directive.
                    _compile.call(directive, element, attr);
                });
            };
            // Return the modified directive.
            return $delegate;
        }
    ]);
}]);
