function loadForm(mentor) {
    $('#indicator').addClass("visible");
    $.get( mentor + "/driver_edit_form", function( data ) {
        $('#form-container').html(data);
    }).always(function() {
        $('#indicator').removeClass("visible");
    });
}

function clearForm() {
    $('#form-container').html("Click a row to begin editing");
}

function registerForm(id) {
    $('#driver-edit-form').submit( function() {
        $('#indicator').addClass("visible");
        $.ajax({
            type: "PUT",
            url: $('#driver-edit-form').attr('action'),
            data: $("#driver-edit-form").serialize(),
            success: function(data)
            {
                $("#mentor_" + parseInt(id)).replaceWith(data);
            }
        })

        return false;
    });
}
