$(document).ready(function () {
  $('#bilge_remove').change(function () {
    $('#file').prop('disabled', $(this).is(':checked'));
  });
});
