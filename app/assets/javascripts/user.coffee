# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('div#show-change-password a').click (event) ->
    event.preventDefault()
    $('div#change-password').fadeIn(1000, "swing")
    $('div#show-change-password').toggle()

anyFindFilter = (name, cert, roles, filter) ->
  return findFilter(name, filter) || findFilter(cert, filter) || findFilter(roles, filter)

findFilter = (div, filter) ->
  return div.textContent.toUpperCase().indexOf(filter) > -1

rowName = (row) ->
  return row.getElementsByClassName('table-cell user')[0].getElementsByClassName('name')[0]

rowCert = (row) ->
  return row.getElementsByClassName('table-cell certificate')[0].getElementsByClassName('certificate')[0]

rowRoles = (row) ->
  return row.getElementsByClassName('table-cell roles')[0]

filterUsers = ->
  input = document.getElementById('user-filter')
  filter = input.value.toUpperCase()

  table = document.getElementById('users')
  rows = Array.prototype.slice.call(table.getElementsByClassName('table-row'))
  rows.splice(0, 1) # Ignore the header row

  shown = []

  for row in rows
    if anyFindFilter(rowName(row), rowCert(row), rowRoles(row), filter)
      $(row).fadeIn(150, "swing")
      shown.push(row)
    else
      $(row).fadeOut(150, "swing")
      row.classList.remove('odd', 'even')

  for show, i in shown
    if i % 2 == 0
      show.classList.remove('odd')
      show.classList.add('even')
    else
      show.classList.remove('even')
      show.classList.add('odd')

$(document).ready ->
  $('#user-filter').keyup ->
    filterUsers()
