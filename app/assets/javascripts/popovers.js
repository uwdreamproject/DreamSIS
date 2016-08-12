var popovers = {

  // A collection of functions that can be used to return dynamic content to popovers.
  // Each function receives the data returned from the server (specified in the `data-url`
  // attribute) and should return the html content for the inside of the popover.
  functions: {
    
    filters: function(data) {
      var content = $("<ul>").addClass("list-unstyled");
      $.each(data, function(name, value) {
        if(value == "fail warn") {
          var li = $("<li>")
            .addClass("text-danger")
            .text(name)
            .prepend("<i class='fa fa-ban fa-fw'></i>")
          content.append(li)
        }
      })
      return content;
    },
    
    followup_notes: function(data) {
      return "test";
    }
    
  }
  
}
