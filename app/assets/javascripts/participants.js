jQuery.fn.submitOnChange = function () {
  $(this).change(function() {
    $('#participants_table').empty().addClass('loading');
    $(this).parent('form').submit();
  });
  return this;
};

$(function () {
  $('select#report').submitOnChange();
});
