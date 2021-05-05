# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('#event_flyer_remove').change ->
    $('#event_flyer_file').prop 'disabled', $(this).is(':checked')
    return
  return

$(document).ready ->
  $('#all_day_check').change ->
    $('#regular_start_time').toggle()
    $('#regular_start_time #event_start_at').prop  'disabled', $(this).is(':checked')
    $('#regular_start_time #event_length_4i').prop 'disabled', $(this).is(':checked')
    $('#regular_start_time #event_length_5i').prop 'disabled', $(this).is(':checked')
    $('#regular_start_time #event_sessions').prop  'disabled', $(this).is(':checked')

    $('#all_day_start_time').toggle()
    $('#all_day_start_time #event_start_at').prop  'disabled', !$(this).is(':checked')
    $('#all_day_start_time #event_length_4i').prop 'disabled', !$(this).is(':checked')
    $('#all_day_start_time #event_length_5i').prop 'disabled', !$(this).is(':checked')
    $('#all_day_start_time #event_sessions').prop  'disabled', !$(this).is(':checked')
    return
  return

markInstructors = (userResults) ->
  validations = document.getElementById('instructors-validation')

  unless userResults
    validations.innerHTML = ''
    return

  validations.innerHTML = '<div class="bold">Found instructors:</div><ul>'

  for user in userResults['users']
    validations.innerHTML += '<li>' + user.name + ' / ' + user.certificate + '</li>'

  validations.innerHTML += '</ul>'

missingInstructors = ->
  validations = document.getElementById('instructors-validation')
  validations.innerHTML = '<div class="red">Cound not find specified instructors.</div><ul>'

verifyInstructors = ->
  authToken = document.getElementById('api-auth-token').innerHTML
  bearerToken = 'Bearer ' + authToken
  input = document.getElementById('instructors')

  request = $.post '/api/v1/verify_user',
    headers: { Authorization: bearerToken }
    usersString: input.value

  request.success (data) -> markInstructors(data)
  request.error (jqXHR, textStatus, errorThrown) -> missingInstructors()

$(document).ready ->
  timeout = null
  $('#instructors').keyup ->
    delayed = ->
      verifyInstructors()
      timeout = null
    if timeout
      clearTimeout(timeout)
    timeout = setTimeout(delayed, 250)