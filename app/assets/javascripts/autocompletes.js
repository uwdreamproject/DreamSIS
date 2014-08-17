// Prep the autocompletes
$(function() {
	$( ".autocomplete-search" ).autocomplete(
	{
    minLength: 3,
		source: null,
		select: function( event, ui ) {
			$(this).val( ui.item.fullname );
      var newLocation = $(this).data("target").replace("id", ui.item.id);
      window.location = newLocation;
      return false;
		},
    create: function() {
      $(this).data('ui-autocomplete')._renderItem = function( ul, item ) {
        return $( "<li>" )
          .append( "<a>" +
            "<span class='primary'>" + item.fullname + "</span>" + 
            "<span class='secondary'>" + item.secondary + "</span>" +
            "<span class='tertiary'>" + item.klass + "</span>" +
            "</a>")
          .appendTo( ul );
      };
      $(this).autocomplete("option", "source", $(this).data("source"));
    }
	});
  
  $("#main-nav > ul > li.trigger-autocomplete > a").click(function(event) {
    $(event.target).parents("li").find("input.search").focus();
    event.preventDefault();
  });
});
