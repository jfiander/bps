openNav = ->
  document.getElementById('sidenav').style.width = '20em'
  return

closeNav = ->
  document.getElementById('sidenav').style.width = '0'
  return

$(document).ready ->
  $('#show-sidenav').click (event) ->
    openNav()
    $('body').addClass 'no-scroll'
    $('#modal').fadeIn 'fast'
    return
  return

$(document).ready ->
  $('#hide-sidenav').click (event) ->
    closeNav()
    $('#modal').fadeOut 'fast'
    $('body').removeClass 'no-scroll'
    return
  return
