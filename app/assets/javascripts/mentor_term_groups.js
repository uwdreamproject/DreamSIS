// Used to show/hide the deleted mentors table on mentor_term_groups#show
function showHideDeletedMentors() {
    deleted_table = $("#deleted_mentors");
    deleted_table.toggle();
    if (deleted_table.is(":visible")) {
        $("#deleted_verb").html("Hide");
    } else {
        $("#deleted_verb").html("Show");
    }
}
