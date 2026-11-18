(() => {
  $(function () {
    $('div#show-change-password a').click(function (event) {
      event.preventDefault();
      $('div#change-password').fadeIn(1000, 'swing');
      $('div#show-change-password').toggle();
    });
  });

  const findFilter = (div, filter) => div.textContent.toUpperCase().indexOf(filter) > -1;

  const anyFindFilter = (name, cert, roles, filter) => (
    findFilter(name, filter) || findFilter(cert, filter) || findFilter(roles, filter)
  );

  const rowName = (row) => row.getElementsByClassName('table-cell user')[0].getElementsByClassName('name')[0];

  const rowCert = (row) => (
    row.getElementsByClassName('table-cell certificate')[0].getElementsByClassName('certificate')[0]
  );

  const rowRoles = (row) => row.getElementsByClassName('table-cell roles')[0];

  const filterUsers = () => {
    const filter = document.getElementById('user-filter').value.toUpperCase();

    const table = document.getElementById('users');
    const rows = Array.from(table.getElementsByClassName('table-row')).slice(1); // Ignore the header row

    const shown = [];

    for (const row of rows) {
      if (anyFindFilter(rowName(row), rowCert(row), rowRoles(row), filter)) {
        $(row).fadeIn(150, 'swing');
        shown.push(row);
      } else {
        $(row).fadeOut(150, 'swing');
        row.classList.remove('odd', 'even');
      }
    }

    shown.forEach((show, i) => {
      if (i % 2 === 0) {
        show.classList.remove('odd');
        show.classList.add('even');
      } else {
        show.classList.remove('even');
        show.classList.add('odd');
      }
    });
  };

  $(document).ready(function () {
    $('#user-filter').keyup(function () {
      filterUsers();
    });
  });
})();
