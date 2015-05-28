function update_event_status_rows(changed) {
	$('#current_rsvp_limit').html(parseInt($("#rsvp_limit").val()));
	$('#current_attended_limit').html(parseInt($("#attended_limit").val()));
	if (changed == "load") {
		changed = document.getElementById("rsvp_limit");
		$(changed).addClass("active")
	}
	if ($(changed).attr("type") == "range") {
		var count = $(changed).val();
	} else {
		changed = $(".active");
	}
	var count = parseInt($(changed).val());
	var changed_string = $(changed).attr("id").split("_")[0];
	$('table#event_status > tbody > tr').each(function(){
		if (parseInt($(this).attr('data-' + changed_string + '-count')) < count) {
			var is_enrolled = parseInt($(this).attr('data-enrolled'));
			if (!is_enrolled && $("#only_enrolled").is(":checked")) {
				$(this).hide();
				$(this).removeClass('visible')
			} else {
				$(this).show();
				$(this).addClass('visible');
			}
		} else {
			$(this).hide();
			$(this).removeClass('visible')
		}
	});
	$('#' + changed_string + '_email_link').show().attr('href', 'mailto:' + $('table#event_status > tbody > tr.visible > td.email > a').map(function(){return this.text}).get().join(', '));
	if (changed_string == "attended") {
		$("#attended_email_link").show();
		$("#rsvp_email_link").hide();
		$("#attended_limit").addClass("active");
		$("#rsvp_limit").removeClass("active");
	} else {
		$("#rsvp_email_link").show();
		$("#attended_email_link").hide();
		$("#rsvp_limit").addClass("active");
		$("#attended_limit").removeClass("active");
	}
}

$(function() {
	$(".update_status_rows_on_change").change(function(event) { update_event_status_rows(event.target)});
})
