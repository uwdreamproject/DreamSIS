// TEMPORARY INCLUSION, WILL BE REMOVED ON MERGE WITH RAILS 3
// ----------------------------------------------------------

// Bind our global "loading" div to all ajax events
$j(document).ajaxStart(function() {
    $j('#indicator').addClass("visible")
// }).ajaxError(function( event, jqxhr, settings, thrownError ) {
//   $('#indicator').removeClass("visible")
//   updateFlashes( { "error" : "There was a problem processing your request. Your data was not saved." })
//   console.log(thrownError)

}).ajaxSuccess(function(event, xhr, settings) {
    var flash = xhr.getResponseHeader('X-Flash-Messages')
    if(!flash) return;
    updateFlashes($j.parseJSON(flash))

}).ajaxStop(function() {
    $j('#indicator').removeClass("visible")
});

$j(function() {
    $j("#notifications .alert").click(function(event) {
        $j(event.target).toggleClass('visible');
    });
});


function clearFlashes() {
    $j('#notice_notification').removeClass('visible')
    $j('#error_notification').removeClass('visible')
    $j('#info_notification').removeClass('visible')
    $j('#saved_notification').removeClass('visible')

    // Wait for a second to clear the text, if it's hidden.
    setTimeout(function() {
        if(!$j('#notice_notification').hasClass('visible')) $j('#notice_notification').html('')
        if(!$j('#error_notification').hasClass('visible')) $j('#error_notification').html('')
        if(!$j('#info_notification').hasClass('visible')) $j('#info_notification').html('')
        if(!$j('#saved_notification').hasClass('visible')) $j('#saved_notification').html('')
    }, 1000)
}

function updateFlashes(flash) {
    if(flash.notice){ $j('#notice_notification').html(flash.notice).addClass('visible') }
    if(flash.error) { $j('#error_notification').html(flash.error).addClass('visible') }
    if(flash.info)  { $j('#info_notification').html(flash.info).addClass('visible') }
    if(flash.saved) { $j('#saved_notification').html(flash.saved).addClass('visible') }
}

// END TEMP INCLUDE --------------------------------

function loadForm(mentor) {
    $j('#indicator').addClass("visible");
    $j.get( mentor + "/driver_edit_form", function( data ) {
        $j('#form-container').html(data);
    }).always(function() {
        $j('#indicator').removeClass("visible");
    });
}

function clearForm() {
    $j('#form-container').html("Click a row to begin editing");
}

function registerForm(id) {
    $j('#driver-edit-form').submit( function() {
        $j('#indicator').addClass("visible");
        $j.ajax({
            type: "PUT",
            url: $j('#driver-edit-form').attr('action'),
            data: $j("#driver-edit-form").serialize(),
            success: function(data)
            {
                $j("#mentor_" + parseInt(id)).replaceWith(data);
            }
        })

        return false;
    });
}