$( document ).ready(function() {      
  applyMobileTableUpdates()
});

/*
  Adds a toggle switch to tables with a td.functions cell.
*/
function applyMobileTableUpdates() {
  var isMobile = window.matchMedia("only screen and (max-width: 640px)");

  if (isMobile.matches) {
    
    $('td.functions').parents("tr").append(
      $( "<td />").addClass("handle").html(
        $("<a href='#'></a>").click( function(e) {
          $( this ).parents("td").siblings("td.functions").toggleClass("visible")
          e.preventDefault()
        })
      )
    )
    
    $('td:not(:has(.before))').each( function(i, elem) {
      var $th = $( this ).closest('table').find('th').eq($( this ).index());      
      if( $( this ).html() && $th.text() ) {        
        $( this ).prepend(
          $("<em />").addClass("before").html($th.text())
        )
      }
    })
    
  }
}