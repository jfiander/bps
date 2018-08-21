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
