// Bind our global "loading" div to all ajax events
$(document).ajaxStart(function() {
  $('#indicator').addClass("visible")
// }).ajaxError(function( event, jqxhr, settings, thrownError ) {
//   $('#indicator').removeClass("visible")
//   updateFlashes( { "error" : "There was a problem processing your request. Your data was not saved." })
//   console.log(thrownError)

}).ajaxSuccess(function(event, xhr, settings) {
  var flash = xhr.getResponseHeader('X-Flash-Messages')
  if(!flash) return;
  updateFlashes($.parseJSON(flash))
  
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
	if(flash.notice){ $('#notice_notification').html(flash.notice).addClass('visible') }
	if(flash.error) { $('#error_notification').html(flash.error).addClass('visible') }
	if(flash.info)  { $('#info_notification').html(flash.info).addClass('visible') }
	if(flash.saved) { $('#saved_notification').html(flash.saved).addClass('visible') }
}