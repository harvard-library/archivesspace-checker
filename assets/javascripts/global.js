$(function () {
  $('input[type="file"]').on('change', function (e) {
    if ($(this).val()) {
      $('input[type="submit"]').prop('disabled', false);
    }
    else {
      $('input[type="submit"]').prop('disabled', true);
    }
  });
});
