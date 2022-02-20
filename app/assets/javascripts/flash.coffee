$ ->
  $('a.close-flash').click (event) ->
    event.preventDefault()
    flash = $(event.target).closest('#flashes div')
    $(flash).fadeOut(500, "swing")
    if flash.attr("id") == "alert"
      $('#flashes #error').fadeOut(500, "swing")
