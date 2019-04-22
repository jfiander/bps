openNav = ->
  document.getElementById('sidenav').style.width = '20em'
  return

closeNav = (id = 'sidenav') ->
  document.getElementById(id).style.width = '0'
  return

closeAllNav = ->
  document.getElementById('sidenav').style.width = '0'
  document.getElementsByClassName('sub-menu')
  for e in document.getElementsByClassName('sub-menu')
	  e.style.width = '0'
  return

openSubNav = (id) ->
  document.getElementById(id).style.width = '18.25em'
  return

openSubSubNav = (id) ->
  document.getElementById(id).style.width = '16.5em'
  return

$(document).ready ->
  $('#show-sidenav').click (event) ->
    openNav()
    $('#nav-modal').fadeIn 'fast'
    $('body').addClass 'no-scroll'
    return
  return

$(document).ready ->
  $('#hide-sidenav').click (event) ->
    closeAllNav()
    $('#nav-modal').fadeOut 'fast'
    $('body').removeClass 'no-scroll'
    return
  return

$(document).ready ->
  $('.close-sidenav').click (event) ->
    id = $(this).attr('id').substr(5)
    closeNav(id)
    return
  return

$(document).ready ->
  $('.show-sub-menu').click ->
    id = $(this).attr('id').substr(5)
    openSubNav(id)
    return

$(document).ready ->
  $('#nav-modal').click ->
    closeAllNav()
    $('#nav-modal').fadeOut 'fast'
    $('body').removeClass 'no-scroll'
    return
