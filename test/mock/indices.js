'use strict';

var mockIndices = (function() {
  return {
    mockIngredients: ['butter', 'milk', 'eggs', 'water'],
    mockIngredientIndex: function() {
      // For the ingredient index, we want something like:
      // {
      //   butter: [],
      //   milk: [0],
      //   eggs: [0, 1],
      //   water: [0, 1, 2]
      // }
      var that = this;
      return _.zipObject(that.mockIngredients, _.map(_.range(that.mockIngredients.length), function(i) {
        return _.range(i);
      }));
    },
    mockRecipeIndex: function() {
      // For the recipe index, we want something like:
      // {
      //   0: {
      //     ingredients: ['butter']
      //   },
      //   1: {
      //     ingredients: ['butter', 'milk', 'dontHaveThisItem1']
      //   },
      //   2: {
      //     ingredients: ['butter', 'milk', 'eggs', 'dontHaveThisItem1', 'dontHaveThisItem2']
      //   },
      //   3: {
      //     ingredients: ['butter', 'milk', 'eggs', 'dontHaveThisItem1', 'dontHaveThisItem2', 'dontHaveThisItem3']
      //   }
      // }
      var that = this;
      return _.zipObject(_.range(that.mockIngredients.length), _.map(_.range(that.mockIngredients.length), function(i) {
        return {
          name: 'Recipe_' + i,
          ingredients: that.mockIngredients.slice(0, i + 1).concat(_.map(_.range(i), function($) {
            return 'dontHaveThisItem' + $;
          })),
          attributes: {
            course: (i % 2 === 0) ? ['Desserts'] : ['Desserts', 'Drinks'],
            cuisine: (i % 2 === 0) ? [] : ['Italian']
          }
        };
      }));
    }
  };
})();
