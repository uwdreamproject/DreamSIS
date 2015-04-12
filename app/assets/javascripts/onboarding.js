function register_onboarding_table_rows() {
    $(".mentor-row").click(function() { loadForm($(this).data("mentor-id")); });
}

function loadForm(mentor) {
    $('#indicator').addClass("visible");
    $.get( mentor + "/onboarding_form", function( data ) {
        $('#form-container').html(data);
    }).always(function() {
        $('#indicator').removeClass("visible");
    });
}

function clearForm() {
    $('#sidebar').html(sidebar_content);
}

function registerOnboardingForm(id) {
    $('#onboarding-form').submit( function(event) {
        $.ajax({
            type: "PUT",
            url: $('#onboarding-form').attr('action'),
            data: $("#onboarding-form").serialize(),
            success: function(data) {
                $("tr[data-mentor-id='" + parseInt(id) + "']").replaceWith(data);
            }
        });
        event.preventDefault();
    });
}
