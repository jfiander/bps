$(document).ready ->
  $('#pay-button').click ->
    $(this).html 'Submitting...'
  return

$ ->
  $('#promo-code').click ->
    window.location = '/pay/' + $('#token').val() + '/' + $('#code').val()
    return
  return
