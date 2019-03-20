showModal = ->
  $('body').addClass 'no-scroll'
  $('#modal').fadeIn 'fast'
  $('#modal-box').fadeIn 'swing'

  $('#modal').on 'click', (e) ->
    if e.target == this
      $(this).fadeOut 'fast'
      $('body').removeClass 'no-scroll'
      return
    return

$(document).ready ->
  $('.modal-link').click (event) ->
    $(this).html 'Done!'
    $(this).addClass 'unclickable'

    showModal()
  return

$(document).ready ->
  $('.modal-form').submit (event) ->
    showModal()
  return
