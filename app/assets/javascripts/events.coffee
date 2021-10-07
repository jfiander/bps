# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('#event_flyer_remove').change ->
    $('#event_flyer_file').prop 'disabled', $(this).is(':checked')
    return
  return

$(document).ready ->
  $('#event_all_day').change ->
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

$(document).ready ->
  $('#event_online').change ->
    $('#online_details').toggle()
    console.log($(this), $(this).is(':checked'))
    $('#online_details #event_conference_id_cache').prop 'disabled', !$(this).is(':checked')
    $('#online_details #event_link_override').prop 'disabled', !$(this).is(':checked')
    return
  return

markInstructors = (userResults) ->
  validations = document.getElementById('instructors-validation')

  unless userResults
    validations.innerHTML = ''
    return

  validations.innerHTML = '<div class="bold">Found instructors:</div><ul>'

  for user in JSON.parse(userResults).users
    validations.innerHTML += '<li>' + user.name + ' / ' + user.certificate + '</li>'

  validations.innerHTML += '</ul>'

missingInstructors = (_errorThrown, responseText) ->
  validations = document.getElementById('instructors-validation')

  message = JSON.parse(responseText).error
  validations.innerHTML = '<div class="red">' + message + '</div>'

verifyInstructors = ->
  authToken = document.getElementById('api-auth-token').innerHTML
  bearerToken = 'Bearer ' + authToken
  usersString = document.getElementById('instructors').value

  req = {
    type: 'POST',
    contentType: 'text/plain',
    dataType: 'text',
    data: usersString,
    headers: { Authorization: bearerToken },
    url: '/api/v1/verify_user'
  }

  request = $.ajax(req);

  request.success (data) -> markInstructors(data)
  request.error (jqXHR, textStatus, errorThrown) -> missingInstructors(errorThrown, jqXHR.responseText)

$(document).ready ->
  timeout = null
  $('#instructors').keyup ->
    delayed = ->
      verifyInstructors()
      timeout = null
    if timeout
      clearTimeout(timeout)
    timeout = setTimeout(delayed, 250)
