'use strict';

angular.module('Kitchen.filters', [])

.filter('categoryFilter', function() {
  // Expect a category string or an empty string to select 'all' recipes.
  //   e.g. 'Beverages' or ''.
  // The property argument is the recipe attribute field to read categories from.
  //   e.g. 'cuisine'.
  return function(recipes, category, property) {
    var predicate = function(recipe) {
      var attribute = recipe.attributes[property] || [];
      return category.length === 0 || _.contains(attribute, category);
    };

    return _.filter(recipes, predicate);
  };
});
