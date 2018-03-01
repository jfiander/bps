# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('#bilge_remove').change ->
    $('#bilge_upload_file').prop 'disabled', $(this).is(':checked')
    return
  return
