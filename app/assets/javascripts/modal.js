(() => {
  const showModal = () => {
    $('body').addClass('no-scroll');
    $('#modal').fadeIn('fast');
    $('#modal-box').fadeIn('swing');

    $('#modal').on('click', function (e) {
      if (e.target === this) {
        $(this).fadeOut('fast');
        $('body').removeClass('no-scroll');
      }
    });
  };

  $(document).ready(function () {
    $('.modal-link').click(function () {
      $(this).html('Done!');
      $(this).addClass('unclickable');

      showModal();
    });
  });

  $(document).ready(function () {
    $('.modal-form').submit(function () {
      showModal();
    });
  });
})();
