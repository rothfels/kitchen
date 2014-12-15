describe('Kitchen Filters', function() {

    var should = chai.should();

    beforeEach(module('Kitchen.filters'));

    describe('categoryFilter', function() {

        var recipes = _.values(mockIndices.mockRecipeIndex());

        it('should correctly filter input recipe object array', inject(function($filter) {
            var categoryFilter = $filter('categoryFilter');
            categoryFilter(recipes, '', 'course').should.have.length(4);
            categoryFilter(recipes, 'Desserts', 'course').should.have.length(4);
            categoryFilter(recipes, 'Drinks', 'course').should.have.length(2);
            categoryFilter(recipes, 'Snacks', 'course').should.have.length(0);
            categoryFilter(recipes, 'Italian', 'cuisine').should.have.length(2);
        }));

    });
});
