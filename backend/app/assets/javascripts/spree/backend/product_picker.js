$.fn.productAutocomplete = function () {
  'use strict';

  function formatProduct(product) {
    return Select2.util.escapeMarkup(product.name);
  }

  this.select2({
    minimumInputLength: 1,
    multiple: true,
    initSelection: function (element, callback) {
      $.get(Spree.routes.product_search, {
        ids: element.val().split(','),
        token: Spree.api_key
      }, function (data) {
        callback(data.products);
      });
    },
    ajax: {
      url: Spree.routes.product_search,
      datatype: 'json',
      data: function (term, page) {
        return {
          q: {
            name_cont: term,
            sku_cont: term
          },
          m: 'OR',
          token: Spree.api_key
        };
      },
      results: function (data, page) {
        var products = data.products ? data.products : [];
        return {
          results: products
        };
      }
    },
    formatResult: formatProduct,
    formatSelection: formatProduct
  });
};

$(document).ready(function () {
  $('.product_picker').productAutocomplete();
});
