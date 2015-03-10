$(function () {
  $('select#report').change(function() {
    $('#participants_table').empty().addClass('loading');
  })
});
