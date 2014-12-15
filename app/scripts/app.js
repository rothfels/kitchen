'use strict';

angular.module('Kitchen', [
  'ionic',
  'Controllers',
  'Kitchen.config',
  'Kitchen.decorators',
  'Kitchen.directives',
  'Kitchen.filters',
  'Kitchen.routes',
])

.run(['$ionicPlatform', 'simpleLogin',
  function($ionicPlatform, simpleLogin) {
    $ionicPlatform.ready(function() {
      // Hide the accessory bar by default.
      // Remove to show the accessory bar above the keyboard for form inputs.
      if (window.cordova && window.cordova.plugins.Keyboard) {
        cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      }
      if (window.StatusBar) {
        // Requires org.apache.cordova.statusbar plugin.
        StatusBar.styleDefault();
      }
    });

    simpleLogin.getUser();
  }
]);
