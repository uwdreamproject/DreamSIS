$(function () {
  
  $('select#report').change(function() {
    $('#participants_table tbody').remove();
    stopLoading = false;
  })
  
  $('.section_score').change(function() {
    updateTotalScore('test_score_total_score', $(this).data("score-calculation-method"))
  })

});

/*
  Updates the "total score" field when editing a TestScore.
*/
function updateTotalScore(total_element_id, calculation_method) {
	var elements = $('.section_score');
	var new_total_score;
	var scores = new Array();
	for(var i=0; i < elements.length; i++) {
		if(elements[i].value != "") {
			scores[i] = parseInt(elements[i].value);
		}
	}
	if (calculation_method == 'average') {
		new_total_score = average(scores);
      } else if (calculation_method == 'rounded-average') {
          new_total_score = average_and_round(scores);
      } else {
		new_total_score = sum(scores);
	}
	$("#" + total_element_id).val(new_total_score);
	return new_total_score;
}

/*
  Shows the control panel for the follow up flag for participants.
*/
function showFollowUpPanel(event) {
  event.preventDefault()
  $(".needs-followup-container .controls").removeClass("current")
  $(this).siblings(".controls").toggleClass("visible").addClass("current")
  $(".needs-followup-container .controls:not(.current)").removeClass("visible")
  $(this).siblings(".controls").find("form textarea").focus()
}

/*
  Enable the click handler for creating follow-up notes.
*/
function prepareFollowupPanels() {
  $('.needs-followup-container > a').on("click", showFollowUpPanel);
}