# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('div#show-change-password a').click (event) ->
    event.preventDefault()
    $('div#change-password').fadeIn(1000, "swing")
    $('div#show-change-password').toggle()
    return
  return

filterUsers = ->
  input = document.getElementById('user-filter')
  filter = input.value.toUpperCase()
  table = document.getElementById('users')
  tr = table.getElementsByTagName('tr')

  i = 0
  while i < tr.length
    name = tr[i].getElementsByTagName('td')[0]
    cert = tr[i].getElementsByTagName('td')[1]
    role = tr[i].getElementsByTagName('td')[2]

    if name || cert || role
      nameValue = name.textContent or name.innerText
      certValue = cert.textContent or cert.innerText
      roleValue = role.textContent or role.innerText

      if nameValue.toUpperCase().indexOf(filter) > -1 || certValue.toUpperCase().indexOf(filter) > -1 || roleValue.toUpperCase().indexOf(filter) > -1
        tr[i].style.display = ''
      else
        tr[i].style.display = 'none'
    i++
  return

$(document).ready ->
  $('#user-filter').keyup ->
    filterUsers()
    return
  return
