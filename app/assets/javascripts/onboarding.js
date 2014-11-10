function loadForm(mentor) {
  $('#indicator').addClass("visible");
  $.get( mentor + "/onboarding_form", function( data ) {
    $('#form-container').html(data);
  }).always(function() {
    $('#indicator').removeClass("visible");
  });
}

function clearForm() {
  $('#form-container').html("Click a row to begin editing");
}

function registerForm(id) {
  $('#onboarding-form').submit( function() {
    $('#indicator').addClass("visible");
    $.ajax({
           type: "PUT",
           url: $('#onboarding-form').attr('action'),
           data: $("#onboarding-form").serialize(),
           success: function(data)
           {
               $("#mentor-" + parseInt(id)).replaceWith(data);
           }
         }).always(function() {
           $('#indicator').removeClass("visible");
         });

    return false;
  });
}
