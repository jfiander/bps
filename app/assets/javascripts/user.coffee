# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('a#show-change-password').click (event) ->
    event.preventDefault()
    $('div#change-password').fadeIn(1000, "swing")
    $('a#show-change-password').toggle()
    return
  return
