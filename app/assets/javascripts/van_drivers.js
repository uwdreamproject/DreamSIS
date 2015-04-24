function register_van_driver_table_rows() {
    clearForm();
    $(".mentor-row").click(function() { getDriverForm($(this).data("mentor-id")); });
}

function clearForm() {
    $('#sidebar').html(sidebar_content);
    $("#check_all_button").click(function() { checkAllCurrentDrivers(); return false; });
}

function registerDriverForm(id) {
    $('#driver-edit-form').submit( function() {
        $('#indicator').addClass("visible");
        $.ajax({
            type: "PUT",
            url: $('#driver-edit-form').attr('action'),
            data: $("#driver-edit-form").serialize(),
            success: function(data) {
                $("tr[data-mentor-id='" + parseInt(id) + "']").replaceWith(data);
            }
        });
        return false;
    });

    $('#check_uwfs_button').click( function() {
	$.ajax({
            type: "POST",
            url: $("#check_uwfs_button").attr('href'),
            success: function(data) {
                if (data["error"] == null) {
                    if (data["saved"] != null) {
                        getDriverForm(id);
                        $("tr[data-mentor-id='" + id + "'] > .uwfs-date").each(function(i){
                            updateUWFSDate($( this ), data["date"]);
                        });
                    } else if (data["changed"] != null) {
                       $('#uwfs-error').html("Mentor is UWFS trained but this could not be saved. Please try again.");
                    }
                } else {
                    $('#uwfs-error').html("Error: " + data["error"]);
                }
             }
        });
        return false;
    });

    registerDateInputHelpers();
}

function checkAllCurrentDrivers() {
    $( document ).on("ajaxStart.checkDrivers", function() {
        errorCount = 0;
        changedCount = 0;
        savedCount = 0;
    }).on("ajaxStop.checkDrivers", function() {
        $( document ).off(".checkDrivers");
        var str = "Updated " + savedCount + " record" + (savedCount != 1 ? "s" : "") + ".";
        if (changedCount - savedCount != 0) {
            str += " However, there were " + (changedCount - savedCount) + " record(s) that were not saved.";
        }
        if (errorCount != 0) {
           str += " Additionally, there were " + errorCount + " error(s).";
        }
        updateFlashes({ "notice" : str });
    });

    var ajaxCount = 0;
    $(".mentor-row").each( function( i ) {
        if ($(this).data("needs-update")) {
            ajaxCount++;
            var id = $( this ).data("mentor-id");
            $.ajax({
                type: "POST",
                url: $("#check_all_button").attr('href').replace("999", id),
                success: function(data) {
                    if (data["error"] != null) {
                        errorCount++;
                        console.log("Error on mentor " + id + ": " + data["error"]);
                    }
                    if (data["changed"] != null) { changedCount++; }
                    if (data["saved"] != null) {
                        savedCount++;
                        if (data["date"] != null) {
                            $("tr[data-mentor-id='" + id + "'] > .uwfs-date").each(function(i){
                                updateUWFSDate($( this ), data["date"]);
                             });
                        }
                    }
                }
            });
        }
    });
    if (ajaxCount == 0) {
        updateFlashes({ "notice" : "All mentors are UWFS trained" });
    }
    return false;
}

function updateUWFSDate(td, dateStr) {
    var date = new Date(dateStr);
    td.html((date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear());
    td.addClass("newly_added");
}

function getDriverForm(id) {
    $.get( parseInt(id) + "/driver_edit_form", function( data ) {
        $('#form-container').html(data);
    });
}
