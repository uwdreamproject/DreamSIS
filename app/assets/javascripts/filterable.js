var Filterable = (function() {
  var filterStatus    = {},
      selector        = "",
      currentRequest  = 0;
  
  var init = {
    
    bindEvents: function() {
      $(document).on('click', ".filters a.filter", function(event) {
        event.preventDefault();
        filters.rotate($(this).data('filter-id'))
      })
      
      $(document).on('click', '.clear-filters', function(event) {
        event.preventDefault();
        filters.clear();
      })

    }
    
  }
  
  var filters = {
    
    // Rotate between pass, fail, and blank
    rotate: function(filterId) {
      var current = filters.get(filterId), next = "";
      if (current == 'pass')
        filters.set(filterId, "fail");
      else if (current == 'fail')
        filters.remove(filterId);
      else
        filters.set(filterId, "pass");
    },
    
    // Get the current value for the specified filter id, or all if blank.
    get: function(filterId) {
      return filterId ? filterStatus[filterId] : filterStatus;
    },
    
    // Set a new value for the specified filter id
    set: function(filterId, status) {
      filterStatus[filterId] = status;
      filters.execute();
      return status;
    },
    
    // Delete a filter from the hash completely.
    remove: function(filterId) {
      var deleted = filterStatus[filterId];
      delete filterStatus[filterId];
      filters.execute();
      return deleted;
    },
    
    // Get the count of active filters
    count: function() {
      return Object.keys(filterStatus).length;
    },
    
    // Returns true if the filters array is currently empty.
    isEmpty: function() {
      return filters.count() <= 0;
    },
    
    // Trigger all of the necessary changes on the page based
    // on the current status of the filters.
    execute: function() {
      display.indicator('show');
      display.update.all();
      
      if (filters.isEmpty()) {
        records.showAll();
        display.indicator('hide');
      } else {
        filters.updateFromServer();
      }
    },

    // Empty out all the filters.
    clear: function() {
      filterStatus = {};
      filters.execute();
    },
    
    // Go check with the server to get the most up to date filter intersection.
    updateFromServer: function() {
      $.getJSON( "/participants/filter_results.json", { filter_selections: filters.get(), currentRequest: ++currentRequest } )
        .done(function( data ) {
          if (data.currentRequest !== String(currentRequest)) {
            console.log("Ignoring out of date response")
            return false; // we're out of date with the current filters.
          }
            
          $(selector).each(function( index ) {
            $(this).toggleClass("hidden", $.inArray( String($(this).data('participant-id')), data.object_ids ) < 0);
            records.count = data.total_record_count;
          });
          display.indicator('hide');
          display.update.count();
        });
    }
    
  }
  
  var records = {
    count: 0,
    
    visible: function() {
      return $(selector + ":visible");
    },
    
    showAll: function() {
      $(selector).removeClass("hidden");
    }
  }
  
  var display = {
    
    // Update all the visual elements in the page that need to be changed.
    update: {
      
      all: function() {
        display.update.controls();
        display.update.count();
        display.update.clearLink();
        display.update.bucket();
        // location hash
      },
    
      // Updates the display of the controls (the links that turn filters on and off).
      controls: function() {
        $("a.filter").each(function() {
          var id = $( this ).data("filter-id");
          var value = filters.get(id);
          $( this ).removeClass("text-success text-danger").find(".fa").removeClass("fa-check fa-ban")
          if(value == 'pass') {
            $( this ).addClass("text-success").find(".fa").addClass("fa-check")
          } else if (value == 'fail') {
            $( this ).addClass("text-danger").find(".fa").addClass("fa-ban")
          } else {
            $( this ).addClass("text-muted")
          }
        })
      },
      
      // Hides or shows the "clear" link based on if there are any filters applied.
      clearLink: function() {
        $("a.clear-filters").toggleClass("hidden", filters.isEmpty());
      },
      
      // Hides or shows the "sorry, no matches" row in the table.
      emptyPlaceholder: function() {
        $('#empty_placeholder').toggleClass("hidden", records.visible().length > 0);
      },
      
      // Updates the record counts
      count: function() {
        $('#filtered_record_count').html(records.visible().length + " of");
        $('header.sub .fa-filter').toggleClass("hidden", filters.isEmpty());
        display.update.emptyPlaceholder();
      },
      
      // Shows little tags for each set filter into the "filter bucket" at the top of the page.
      bucket: function() {
        $("#filter_bucket > li:not(:first-child)").remove();
        $.each(filters.get(), function (key, value) {
          var newTag = $("<li />");
          newTag.text($('[data-filter-id=\'' + key + '\'] > .filter-title').text());
          if (value == "fail")
            newTag.addClass("text-danger").prepend($("<i class='fa fa-ban fa-fw'></i>"));
          else if (value == "pass")
            newTag.addClass("text-success").prepend($("<i class='fa fa-check fa-fw'></i>"));
          $("#filter_bucket").append(newTag);
        });
      }
      
    },
    
    indicator: function(command) {
      $(".indicator.participants").toggleClass("hidden", command == 'hide')
    }
    
  }
  
  return {
    initialize: function(_selector) {
      selector = _selector;
      init.bindEvents();
    },
    filters: filters,
    display: display,
    records: records
  }
})();

$(function() {
  Filterable.initialize(".filterable")
})

//   // Add rows that match the selected stages
//   $("#stages_selector [data-stage].selected").each(function( i, element) {
//     selection += "[data-stages~=" + $(this).data("stage") + "]"
//   })
//
//
// /*
//   Function to call when a Stage selector is clicked.
// */
// function clickStageSelector(event) {
//   event.preventDefault()
//   $( this ).toggleClass("selected")
//   updateLocationHashWithFilters()
//   executeFilters()
// }
//
// /*
//   Updates the hash in the URL with the selected filterables and stages.
// */
// function updateLocationHashWithFilters() {
//   var filterHash = []
//   $("a.filter.enabled").each(function (i, element) {
//      filterHash.push($(this).data("filter-id") + ":" + $(this).data("value"))
//   })
//
//   var stagesHash = []
//   $("#stages_selector [data-stage].selected").each(function( i, element) {
//     stagesHash.push($(this).data("stage"))
//   })
//
//   var newHash = []
//   if (stagesHash.length > 0)
//     newHash.push("stages=" + stagesHash.join(","));
//   if (filterHash.length > 0)
//     newHash.push("filters=" + filterHash.join(","));
//
//   window.location.hash = "#!" + newHash.join("&")
// }
//
// /*
//   Updates filter selections with the values in the location hash.
// */
// function updateFiltersWithLocationHash(otherHash) {
//   var currentHash = otherHash || window.location.hash
//   var hashParts = currentHash.replace("#!", "").split("&")
//   for (var i=0; i < hashParts.length; i++) {
//     if (hashParts[i].length > 0) {
//       var key = hashParts[i].split("=")[0], stringValue = hashParts[i].split("=")[1]
//
//       if (key == "filters") {
//         // stringValue looks like "1:pass,2:pass,3:fail"
//         var value = stringValue.split(",")
//         for (var j=0; j < value.length; j++) {
//           var filter_id = value[j].split(":")[0], filter_value = value[j].split(":")[1]
//           $("a.filter[data-filter-id=" + filter_id + "]").addClass("enabled").data("value", filter_value)
//         }
//       }
//
//       if (key == "stages") {
//         // stringValue looks like "planning,enrolled"
//         for (var j=0; j < stringValue.split(",").length; j++) {
//           $("#stages_selector [data-stage='" + stringValue.split(",")[j] + "']").addClass("selected")
//         }
//       }
//     }
//
//     executeFilters()
//   }
// }
