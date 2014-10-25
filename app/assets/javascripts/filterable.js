$( function() {
  executeFilters()
  $(".filter_checkbox").change(executeFilters)
})

function executeFilters() {
  if( $(".filter_checkbox:checked").length === 0 ) {
    showAllFilterables()
  } else {
    $(".filterable").addClass("hidden")
    selection = ""
    $(".filter_checkbox:checked").each(function (i, element) {
      selection += "[data-filter-" + $(this).data("target-filter-id") + "='" + $(this).val() + "']"
    })
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
  $(".filter_checkbox").each(function(i) {
    $(this).siblings("small").html( 
      $(".filterable:not(.hidden)[data-filter-" + $(this).data("target-filter-id") + "='true']" ).size() 
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