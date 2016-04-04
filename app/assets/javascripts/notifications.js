// Bind our global "loading" div to all ajax events
$(document).ajaxStart(function() {
  $('#indicator').addClass("visible")

}).ajaxError(function( event, xhr, settings, thrownError ) {
  $('#indicator').removeClass("visible")
  if (thrownError == "Forbidden") {
    var msg = "Sorry, you aren't allowed to access that record."
  } else {
    var msg = "There was a problem processing your request. If you were trying to save a record, your data was probably not saved."
  }
  updateFlashes( { "error" : msg })
  console.log(thrownError)

}).ajaxSuccess(function(event, xhr, settings) {
  var flash = xhr.getResponseHeader('X-Flash-Messages')
  if(!flash) return;
  updateFlashes($.parseJSON(flash))
  applyMobileTableUpdates()
  
}).ajaxStop(function() {
	$('#indicator').removeClass("visible")
});

$(function() {
  $("#notifications .alert").click(function(event) {
    $(event.target).toggleClass('visible');
  });
});


function clearFlashes() {
	$('#notice_notification').removeClass('visible')
	$('#error_notification').removeClass('visible')
	$('#info_notification').removeClass('visible')
	$('#saved_notification').removeClass('visible')
	
	// Wait for a second to clear the text, if it's hidden.
	setTimeout(function() {
		if(!$('#notice_notification').hasClass('visible')) $('#notice_notification').html('')
		if(!$('#error_notification').hasClass('visible')) $('#error_notification').html('')
		if(!$('#info_notification').hasClass('visible')) $('#info_notification').html('')
		if(!$('#saved_notification').hasClass('visible')) $('#saved_notification').html('')
	}, 1000)
}

function updateFlashes(flash) {
	if(flash.notice){ $('#notice_notification').text(flash.notice).addClass('visible') }
	if(flash.error) { $('#error_notification').text(flash.error).addClass('visible') }
	if(flash.info)  { $('#info_notification').text(flash.info).addClass('visible') }
	if(flash.saved) { $('#saved_notification').text(flash.saved).addClass('visible') }
}

/*
Turn the primary "Loading" indicator into a progress bar and update the progress bar's width.  
*/
function updateLoadProgress(new_size) {
  if (typeof(new_size) == "number")
    new_size = "" + (new_size * 100) + "%"
  $("#indicator").addClass("progress")
  $("#indicator .size").css({ width: new_size })
  return new_size
}
var stopLoading = false;

/*
  Revert the primary "Loading" indicator back into a regular spinner without progress bar.
*/
function hideLoadProgress() {
  $("#indicator").removeClass("progress")
  $("#indicator .size").css({ width: 0 })
}

$(function() {
  $("#indicator a.stop-loading").click(function(event) {
    event.preventDefault();
    console.log("User requested to stop the loading process")
    stopLoading = true;
  })
})
