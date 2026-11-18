(() => {
  $(document).ready(function () {
    $('#event_flyer_remove').change(function () {
      $('#event_flyer_file').prop('disabled', $(this).is(':checked'));
    });
  });

  $(document).ready(function () {
    $('#event_all_day').change(function () {
      const allDay = $(this).is(':checked');

      $('#regular_start_time').toggle();
      $('#regular_start_time #event_start_at').prop('disabled', allDay);
      $('#regular_start_time #event_length_4i').prop('disabled', allDay);
      $('#regular_start_time #event_length_5i').prop('disabled', allDay);
      $('#regular_start_time #event_sessions').prop('disabled', allDay);

      $('#all_day_start_time').toggle();
      $('#all_day_start_time #event_start_at').prop('disabled', !allDay);
      $('#all_day_start_time #event_length_4i').prop('disabled', !allDay);
      $('#all_day_start_time #event_length_5i').prop('disabled', !allDay);
      $('#all_day_start_time #event_sessions').prop('disabled', !allDay);
    });
  });

  $(document).ready(function () {
    $('#event_online').change(function () {
      $('#online_details').toggle();
      $('#online_details #event_conference_id_cache').prop('disabled', !$(this).is(':checked'));
      $('#online_details #event_link_override').prop('disabled', !$(this).is(':checked'));
    });
  });

  const markInstructors = (userResults) => {
    const validations = document.getElementById('instructors-validation');

    if (!userResults) {
      validations.innerHTML = '';
      return;
    }

    validations.innerHTML = '<div class="bold">Found instructors:</div><ul>';

    for (const user of JSON.parse(userResults).users) {
      validations.innerHTML += '<li>' + user.name + ' / ' + user.certificate + '</li>';
    }

    validations.innerHTML += '</ul>';
  };

  const missingInstructors = (_errorThrown, responseText) => {
    const validations = document.getElementById('instructors-validation');

    const message = JSON.parse(responseText).error;
    validations.innerHTML = '<div class="red">' + message + '</div>';
  };

  const verifyInstructors = () => {
    const authToken = document.getElementById('api-auth-token').innerHTML;
    const usersString = document.getElementById('instructors').value;

    const request = $.ajax({
      type: 'POST',
      contentType: 'text/plain',
      dataType: 'text',
      data: usersString,
      headers: {
        Authorization: 'JWT ' + authToken
      },
      url: '/api/v1/verify_user'
    });

    request.success((data) => markInstructors(data));
    request.error((jqXHR, _textStatus, errorThrown) => missingInstructors(errorThrown, jqXHR.responseText));
  };

  $(document).ready(function () {
    let timeout = null;

    $('#instructors').keyup(function () {
      if (timeout) {
        clearTimeout(timeout);
      }

      timeout = setTimeout(() => {
        verifyInstructors();
        timeout = null;
      }, 250);
    });
  });

  $(document).ready(function () {
    $('.show-event-actions-list').click(function (event) {
      event.preventDefault();
    });
  });
})();
