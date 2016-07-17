document.addEventListener "turbolinks:load",  ->
  $(document).ajaxStart ->
    $("#progress").stop(true, true).fadeIn()

  $(document).ajaxStop ->
    $("#progress").fadeOut()
