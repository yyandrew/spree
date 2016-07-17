document.addEventListener("turbolinks:load", function() {
  // Make select beautiful
  $('select.select2').select2({
    allowClear: true,
    dropdownAutoWidth: true
  });
});
