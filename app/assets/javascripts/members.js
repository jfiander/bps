$(function () {
  $('form.edit_static_page textarea').each(function () {
    $(this).height($(this).prop('scrollHeight'));
  });
});

$(document).ready(function () {
  $('#minutes_remove').change(function () {
    $('#file').prop('disabled', $(this).is(':checked'));
  });
});

$(function () {
  $('a#show-markdown-help').click(function (event) {
    event.preventDefault();
    $('div#markdown-help').fadeIn(1000, 'swing');
    $('a#show-markdown-help').toggle();
  });
});
