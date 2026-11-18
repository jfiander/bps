(() => {
  const openNav = () => {
    document.getElementById('sidenav').style.width = '20em';
  };

  const closeNav = (id = 'sidenav') => {
    document.getElementById(id).style.width = '0';
  };

  const closeAllNav = () => {
    document.getElementById('sidenav').style.width = '0';

    for (const e of document.getElementsByClassName('sub-menu')) {
      e.style.width = '0';
    }
  };

  const openSubNav = (id) => {
    document.getElementById(id).style.width = '18.25em';
  };

  $(document).ready(function () {
    $('#show-sidenav').click(function () {
      openNav();
      $('#modal').fadeIn('fast');
      $('body').addClass('no-scroll');
    });
  });

  $(document).ready(function () {
    $('#hide-sidenav').click(function () {
      closeAllNav();
      $('#modal').fadeOut('fast');
      $('body').removeClass('no-scroll');
    });
  });

  $(document).ready(function () {
    $('.close-sidenav').click(function () {
      closeNav($(this).attr('id').substr(5));
    });
  });

  $(document).ready(function () {
    $('.show-sub-menu').click(function () {
      openSubNav($(this).attr('id').substr(5));
    });
  });

  $(document).ready(function () {
    $('#modal').click(function () {
      closeAllNav();
      $('#modal').fadeOut('fast');
      $('body').removeClass('no-scroll');
    });
  });
})();
