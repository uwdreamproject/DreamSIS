// Initialize autocompletes on page load
$(function() {
	prepAutocompletes();
  
  $("#main-nav > ul > li.trigger-autocomplete > a").click(function(event) {
    $(event.target).parents("li").find("input.search").focus();
    event.preventDefault();
  });
});

// Prep the autocompletes on the page
function prepAutocompletes() {
	$( ".autocomplete-search" ).autocomplete(
	{
    minLength: 2,
		source: null,
		select: function( event, ui ) {
			$(this).val( ui.item.fullname );
      if ( $(this).data("target") ) {
        var newLocation = $(this).data("target").replace("id", ui.item.id);
        window.location = newLocation;
      }
      if ( $(this).data("after-select") == 'display-details') {
        display_autocomplete_details(ui.item, $("#" + $(this).data('details-container')))
        $(this).hide()
      }
      if ( $(this).data("update-with-id") ) {
        $("#" + $(this).data('update-with-id')).val(ui.item.id)
      }
      return false;
		},
    create: function() {
      $(this).data('ui-autocomplete')._renderItem = function( ul, item ) {
        return $( "<li>" )
          .append( "<a>" +
            "<span class='primary'>" + item.fullname + "</span>" + 
            "<span class='secondary'>" + item.secondary + "</span>" +
            "<span class='tertiary'>" + item.klass + " " + item.id + "</span>" +
            "</a>")
          .appendTo( ul );
      };
      $(this).autocomplete("option", "source", $(this).data("source"));
    }
	}).attr("spellcheck", "false").attr("autocomplete", "off").attr("autocapitalize", "off");
}

function display_autocomplete_details(item, container) {
  container.find(".primary").html(item.fullname)
  container.find(".id").html("(#" + item.id + ")")
  container.find(".secondary").html(item.secondary)
  container.find(".tertiary").html(item.klass)
  container.show()
}