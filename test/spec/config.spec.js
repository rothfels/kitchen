'use strict';

describe('Kitchen Config', function() {

    var should = chai.should();

    beforeEach(module('Kitchen.config'));

    it('should have a valid FBURL', inject(function(FBURL) {
        FBURL.should.match(/^https:\/\/[a-zA-Z_-]+\.firebaseio\.com$/i);
    }));

    it('should have a valid SEMVER version', inject(function(version) {
        version.should.match(/^\d\d*(\.\d+)+$/);
    }));
});
