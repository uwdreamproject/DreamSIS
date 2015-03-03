$( function() {
  updateFiltersWithLocationHash()
  executeFilters()
  $(".filter_checkbox").change(changeFilterCheckbox)
  $("#stages_selector a").click(clickStageSelector) // Add this after the ajax call, too
})

function executeFilters() {
  if( $(".filter_checkbox:checked").length === 0 && $("#stages_selector [data-stage].selected").length === 0 ) {
    showAllFilterables()
  } else {
    $(".filterable").addClass("hidden")
    selection = ""

    // Add rows that match the selected stages
    $("#stages_selector [data-stage].selected").each(function( i, element) {
      selection += "[data-stages~=" + $(this).data("stage") + "]"
    })

    // Add rows that match the selected filters
    $(".filter_checkbox:checked").each(function (i, element) {
      selection += "[data-filter-" + $(this).data("target-filter-id") + "='" + $(this).val() + "']"
    })

    // Show all the rows in the selection
    $(selection).removeClass("hidden")
  }
  updateRecordCount()
}

// shows all the filterable items to give us a clean slate before running executeFilters()
function showAllFilterables() {
  $(".filterable").removeClass("hidden")
}

// // Adds the "preview_filter" CSS class to the filter elements but doesn't hide them
// function previewFilter(filter_key) {
//   elements = filterables[filter_key][true]
//   elements.addClass('preview')
// }
//
// function unpreviewFilter(filter_key) {
//   elements = filterables[filter_key][true]
//   elements.removeClass('preview')
// }

// Shows everything and unchecks all the checkboxes
function clearAllFilters() {
  showAllFilterables()
  $('.filter_checkbox').each(function(e) { $(this).attr("checked", false) }) // uncheck all the boxes to start
  updateRecordCount()
}

// Tries to update a div with id "filtered_record_count" with the number of filterables that are visible.
function updateRecordCount(filter_key) {
  $('#filtered_record_count').html($('.filterable:not(.hidden)').size() + " of")
  $('#total_record_count').html($('.filterable').size())
  $(".filter_checkbox").each(function(i) {
    $(this).siblings("small").html( 
      $(".filterable:not(.hidden)[data-filter-" + $(this).data("target-filter-id") + "='true']" ).size() 
    ) 
  })
  updateFilterBucket()
}

/*
  Shows little tags for each set filter into the "filter bucket" at the top of the page.
*/
function updateFilterBucket() {
  $("#filter_bucket").html("")
  $(".filter_checkbox:checked").each(function (i, element) {
    $("#filter_bucket").append(
      $("<span />").addClass("outline filter tag").text(
        $( this ).siblings("span").text()
      )
    )
  })
}

// // Sets a filter using some shortcuts and then executes the new filter. Valid options for 'type' are:
// //   'only'  - shows just the value that's passed
// //   'all'  - shows all filterables in this category
// //   'none'  - shows none of the filterables in this category (this is the default)
// function setFilter(type, filter_key, value) {
//   value += ''  // convert int to string
//   if (filter_key === undefined) {
//     filter_key = ''
//   }
//   // appliedFilters.get(filter_key).clear() // filter everything to start
//   $('.' + filter_key + '_filter_checkbox').each(function(e) {e.checked = false}) // uncheck all the boxes to start
//   if (type == 'only') {
//     // appliedFilters.get(filter_key).push(value)
//     appliedFilters[filter_key] = value
//     dom_id = "filter_" + filter_key + "_" + value
//     $(dom_id).checked = true
//   }
//   if (type == 'all') {
//     appliedFilters[filter_key] = filters[filter_key].clone()
//     $('.' + filter_key + '_filter_checkbox').each(function(e) {e.checked = true})
//   }
//   executeFilters();
// }

/*
  Filters a list of location items by county. Add a class name of "filterable-by-county" for all
  filterable elements, and a class of "county-{value}" to define which county the element is in.
*/
function filterByCounty(filter_value) {
  if(filter_value == 'reset') {
    $('.filterable-by-county').show();
    window.location.hash = ""
  } else {
    $('.filterable-by-county').hide();
    $('.filterable-by-county.county-' + filter_value).show()
    window.location.hash = "filter-county=" + filter_value
  }
}

/*
  Function to call when a filter checkbox is changed.
*/
function changeFilterCheckbox() {
  updateLocationHashWithFilters()
  executeFilters()
}

/*
  Function to call when a Stage selector is clicked.
*/
function clickStageSelector(event) {
  event.preventDefault()
  $( this ).toggleClass("selected")
  updateLocationHashWithFilters()
  executeFilters()
}

/*
  Updates the hash in the URL with the selected filterables and stages.
*/
function updateLocationHashWithFilters() {
  var filterHash = []
  $(".filter_checkbox:checked").each(function (i, element) {
     filterHash.push($(this).data("target-filter-id") + "|" + $(this).val())
  })
  
  var stagesHash = []
  $("#stages_selector [data-stage].selected").each(function( i, element) {
    stagesHash.push($(this).data("stage"))
  })
  
  var newHash = []
  if (stagesHash.length > 0)
    newHash.push("stages=" + stagesHash.join(","));
  if (filterHash.length > 0)
    newHash.push("filters=" + filterHash.join(","));
  
  window.location.hash = "#!" + newHash.join("&")
}

/*
  Updates filter selections with the values in the location hash.
*/
function updateFiltersWithLocationHash() {
  var currentHash = window.location.hash
  var hashParts = currentHash.replace("#!", "").split("&")
  for (var i=0; i < hashParts.length; i++) {
    if (hashParts[i].length > 0) {      
      var key = hashParts[i].split("=")[0], stringValue = hashParts[i].split("=")[1]
      
      if (key == "filters") {
        // stringValue looks like "1|true,2|true,3|true"
        var value = stringValue.split(",")
        for (var j=0; j < value.length; j++) {
          var filter_id = value[j].split("|")[0], filter_value = value[j].split("|")[1]
          $(".filter_checkbox[data-target-filter-id=" + filter_id + "]").attr("checked", true)
        }
      }
      
      if (key == "stages") {
        // stringValue looks like "planning,enrolled"
        for (var j=0; j < stringValue.split(",").length; j++) {
          $("#stages_selector [data-stage='" + stringValue.split(",")[j] + "']").addClass("selected")
        }
      }
    }

    executeFilters()
  }
}
