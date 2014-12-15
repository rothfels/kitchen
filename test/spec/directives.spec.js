'use strict';

describe('directives', function() {

    var should = chai.should();

    function stubSimpleLogin() {
        var listeners = [];
        var stub = {};
        stub.watch = function(cb) {
            listeners.push(cb);
        };
        stub.$$notify = function() {
            var args = Array.prototype.slice.call(arguments);
            angular.forEach(listeners, function(fn) {
                fn.apply(null, args);
            });
        };
        return stub;
    }


    beforeEach(module('Kitchen.directives'));

    describe('app-version', function() {
        it('should print current version', function() {
            module(function($provide) {
                $provide.constant('version', 'TEST_VER');
            });
            inject(function($compile, $rootScope) {
                var element = $compile('<span app-version></span>')($rootScope);
                element.text().should.equal('TEST_VER');
            });
        });
    });

    describe('ngShowAuth', function() {
        var $q, $timeout, $scope, element, stub, spy;
        beforeEach(function() {
            module(function($provide) {
                stub = stubSimpleLogin();
                spy = sinon.spy(stub, 'watch');
                $provide.factory('simpleLogin', function() {
                    return stub;
                });
            });
            inject(function($compile, $rootScope, _$q_, _$timeout_) {
                $scope = $rootScope.$new();
                element = $compile('<span ng-show-auth></span>')($scope);
                $q = _$q_;
                $timeout = _$timeout_;
            });
        });

        it('should hide elements initially', function() {
            element.hasClass('ng-cloak').should.be.true;
            spy.should.have.been.calledTwice;
        });

        it('should show if logged in after resolve', function() {
            stub.$$notify({
                uid: 'test123'
            });
            $timeout.flush();
            element.hasClass('ng-cloak').should.be.false;
            spy.should.have.been.calledTwice;
        });

        it('should stay hidden if not logged in after resolve', function() {
            stub.$$notify(null);
            $timeout.flush();
            element.hasClass('ng-cloak').should.be.true;
            spy.should.have.been.calledTwice;
        });

        it('should update if the auth status changes', function() {
            stub.$$notify(null);
            $timeout.flush();
            stub.$$notify({
                uid: 'test123'
            });
            $timeout.flush();
            element.hasClass('ng-cloak').should.be.false;
            spy.should.have.been.calledTwice;
        });
    });

    describe('ngHideAuth', function() {
        var $q, $timeout, $scope, element, stub, spy;
        beforeEach(function() {
            module(function($provide) {
                stub = stubSimpleLogin();
                spy = sinon.spy(stub, 'watch');
                $provide.value('simpleLogin', stub);
            });
            inject(function($compile, $rootScope, _$q_, _$timeout_) {
                $scope = $rootScope.$new();
                element = $compile('<span ng-hide-auth></span>')($scope);
                $q = _$q_;
                $timeout = _$timeout_;
            });
        });

        it('should hide elements initially', function() {
            element.hasClass('ng-cloak').should.be.true;
            spy.should.have.been.calledTwice;
        });

        it('should stay hidden if logged in after resolve', function() {
            stub.$$notify({
                uid: 'test123'
            });
            $timeout.flush();
            element.hasClass('ng-cloak').should.be.true;
            spy.should.have.been.calledTwice;
        });

        it('should show if not logged in after resolve', function() {
            stub.$$notify(null);
            $timeout.flush();
            element.hasClass('ng-cloak').should.be.false;
            spy.should.have.been.calledTwice;
        });

        it('should update if the auth status changes', function() {
            stub.$$notify(null);
            $timeout.flush();
            stub.$$notify({
                uid: 'test123'
            });
            $timeout.flush();
            element.hasClass('ng-cloak').should.be.true;
            spy.should.have.been.calledTwice;
        });
    });
});
