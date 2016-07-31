// Hide the global search when the user clicks anywhere else on screen.
$(document).on('click', function(e) {
  if ($("#nav-global-search").has($(e.target)).length) {
    e.preventDefault();
    $("#nav-global-search").removeClass('minimized').find("input.search").focus();
  } else {
    $("#nav-global-search").addClass("minimized");
  }
})

// Initialize the global search on each page/turbolinks load.
$(document).on('turbolinks:load', function() {

    var allRecords = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace(['name', 'email']),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: {
        url: '/search.json?q=%QUERY',
        wildcard: '%QUERY'
      }
    });

    $('.global-search').typeahead({
        hint: true,
        highlight: true,
        minLength: 1
      }, {
        name: 'all-records',
        display: 'fullname',
        source: allRecords,
        limit: 10,
        templates: {
          empty: "<p class='text-warning'>Sorry, couldn't find anything!</p>",
          suggestion: function(data) {
            return suggestionContent(data);
          },
          pending: "<p class='loading'><i class='fa fa-spin fa-spinner'></i> Searching...</p>",
          footer: function(query, suggestions) {
            return "<a href='/search?q=" + query.query + "'>Advanced Search</a>" +
              "<p class='small text-muted footer'><b>Tip:</b> Search at any time by pressing the <kbd>/</kbd> key.</p>";
          }
        }
      })
      .attr("spellcheck", "false")
      .attr("autocomplete", "off")
      .attr("autocapitalize", "off")
      .on('typeahead:select', function(ev, suggestion) {
        console.log($(this));
        if ($(this).data('action') == 'navigate') {
          Turbolinks.visit(suggestion.url);
        } else {
          alert("This feature is still under construction.")
        }
      });

    // Focus on the global search if the "/" key is pressed.
    $(document).keydown(function(event) {
      if ($(event.target).is('input, textarea, select, [contenteditable]')) {
        return;
      }
      if (event.which == 191) {
        event.preventDefault();
        $("#nav-global-search").removeClass('minimized').find("input.search").focus();
      }
    })



  })
  // Returns a block of HTML for displaying a typeahead suggestion. The result is dependent
  // on the type of object that's been found, for example a 'Participant' object will include
  // information about the person's cohort membership in the search result.
function suggestionContent(data) {
  var name = data.name;
  var icon = "user";
  var details = [data.type + ' #' + data.id]


  switch (data.type) {
    case "Mentor":
    case "Parent":
    case "Participant":
      icon = "graduation-cap";
    default:
      details.push(data.email);
      break;
    case "Visit":
    case "Event":
      icon = "calendar-o";
      break;
    case "HighSchool":
      icon = "map-marker";
      break;
    case "Institution":
      icon = "institution";
      break;
  }
  var compiled_details = $.map(details, function(v) {
    return v === "" ? null : v;
  }).join(" &bull; ");

  return [
    "<div class='suggestion media'>",
    "<div class='media-left'>",
    "<i class='fa fa-fw fa-" + icon + " media-object' aria-hidden='true'></i>",
    "</div>",
    "<div class='media-body'>",
    "<strong class='name'>" + name + "</strong>",
    "<p class='text-muted small'>" + compiled_details + "</p>",
    "</div>",
    "</div>"
  ].join("\n");
}