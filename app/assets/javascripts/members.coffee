# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('form.edit_static_page textarea').each ->
    $(this).height $(this).prop('scrollHeight')
    return
  return

$(document).ready ->
  $('#minutes_remove').change ->
    $('#minutes_upload_file').prop 'disabled', $(this).is(':checked')
    return
  return

$ ->
  $('a#show-markdown-help').click (event) ->
    event.preventDefault()
    $('div#markdown-help').fadeIn(1000, "swing")
    $('a#show-markdown-help').toggle()
    return
  return