$(function () {
  $('input[type="file"]').on('change', function (e) {
    if ($(this).val()) {
      $('input[type="submit"]').prop('disabled', false);
    }
    else {
      $('input[type="submit"]').prop('disabled', true);
    }
  });
  $('input[name="format"]').on('change', function (e) {
    var action = $('form').prop('action'),
        new_action = action.replace(/\.[^.]+$/, '.' + $(this).val());
    $('form').prop('action', new_action);
  });

  $('input[name="format"]').trigger('change');
});
