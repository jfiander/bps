$(document).ready(function () {
  $('#location_picture_remove').change(function () {
    $('#location_picture_file').prop('disabled', $(this).is(':checked'));
  });
});
