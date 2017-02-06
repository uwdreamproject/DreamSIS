(function() {
  this.App || (this.App = {});

  App.filterable = (function() {
    var filterStatus    = {},
        selector        = "",
        currentRequest  = 0;
          
    var init = {
      
      bindEvents: function() {
        $(document).on('click', "a.filter", function(event) {
          event.preventDefault();
          if ($(this).parents('[data-value]').length > 0) {
            var filter_id = $(this).parents('[data-filter-id]').data('filter-id')
            var value = $(this).parents('[data-value]').data('value')
            filters.rotate.grouping(filter_id, value)
          } else {
            filters.rotate.passfail($(this).data('filter-id'))
          }
        })
        
        $(document).on('click', '.clear-filters', function(event) {
          event.preventDefault();
          filters.clear();
        })
        
        $(document).on('click', '.dropdown-menu[data-trigger=ignore]', function (event) {
          event.stopPropagation();
        });
        
        $(document).on('click', '.bulk_actions li.select-all > a', function(event) {
          event.preventDefault();
          records.selectAll()
        })
          
        $(document).on('change', 'input:checkbox.select-all', function(event) {
          if( $(this).is(':checked') )
            records.selectAllVisible()
          else
            records.unselectAllVisible()
        })
        
        $(document).on('click', '.filterable[data-participant-id] input:checkbox.index_check_box', function(event) {
          if( $(this).is(':checked') )
            selections.add( $(this).parents('.filterable') )
          else
            selections.remove( $(this).parents('.filterable') )
        })
        
        $(document).on('click', ".navigation-controls a, .navigation-controls button:not(.dropdown-toggle)", function(event) {
          event.preventDefault()
          if ($(this).hasClass('next')) display.navigation.nextPage()
          if ($(this).hasClass('prev')) display.navigation.prevPage()
          if ($(this).data('page')) display.navigation.goToPage($(this).data('page'))
        })
        
        $(document).on('click', ".report-select > li > a", function(event) {
          event.preventDefault()
          $(".report-select .active").removeClass('active')
          $(this).parent().addClass('active')
          records.fetchFromServer()
        })

      },
      
      stickyHeaders: function() {
        $('table').stickyTableHeaders('destroy')
        return $('table').stickyTableHeaders({ fixedOffset: $('header.sub') })
      }
      
    }
    
    var filters = {
      
      rotate: {
      
        // Rotate between pass, fail, and blank
        passfail: function(filterId) {
          var current = filters.get(filterId), next = "";
          if (current == 'pass')
            filters.set(filterId, 'fail');
          else if (current == 'fail')
            filters.remove(filterId);
          else
            filters.set(filterId, 'pass');
        },
        
        // Rotate between on and off (for cohort groups)
        grouping: function(filterId, value) {
          if (filters.get(filterId) == value)
            filters.remove(filterId)
          else if (value == 'any')
            filters.remove(filterId)
          else
            filters.set(filterId, value)
        }
        
      },
      
      // Get the current value for the specified filter id, or all if blank.
      get: function(filterId) {
        return filterId ? filterStatus[filterId] : filterStatus;
      },
      
      // Set a new value for the specified filter id
      set: function(filterId, status) {
        filterStatus[filterId] = status;
        selections.clear();
        filters.execute();
        return status;
      },
      
      // Delete a filter from the hash completely.
      remove: function(filterId) {
        var deleted = filterStatus[filterId];
        delete filterStatus[filterId];
        selections.clear();
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
        filters.updateFromServer();
        display.update.all();
      },

      // Empty out all the filters.
      clear: function() {
        filterStatus = {};
        filters.execute();
      },
      
      // Go check with the server to get the most up to date filter intersection.
      updateFromServer: function() {
        $.getJSON( "/participants/filter_results.json", {
          filter_selections: filters.get(),
          currentRequest: ++currentRequest
        } )
          .done(function( data ) {
            if (data.currentRequest !== String(currentRequest)) {
              console.log("Ignoring out of date response")
              return false; // we're out of date with the current filters.
            }
            
            records.count = data.total;
            records.objectIds = data.object_ids;
            display.indicator('hide');
            display.update.groupings(data.groupings);
            display.update.count();
            records.fetchFromServer();
          });
      }
      
    }
    
    var records = {
      count: 0,
      objectIds: [],
      
      visible: function() {
        return $(selector + ":visible");
      },
      
      showAll: function() {
        $(selector).removeClass("hidden");
      },
      
      selectAll: function() {
        selections.objectIds = records.objectIds.slice()
        display.update.selections()
      },
      
      selectAllVisible: function() {
        records.visible().each(function() {
          selections.add( $(this), false )
        })
        display.update.selections()
      },
      
      unselectAllVisible: function() {
        records.visible().each(function() {
          selections.remove( $(this), false )
        })
        display.update.selections()
      },
      
      hiddenCount: function() {
        return records.objectIds.length - records.visible().length
      },
      
      fetchFromServer: function() {
        display.indicator('show')
        $.getJSON( "participants", {
          report: display.reportType(),
          ids: records.objectIds,
          page: display.currentPage,
          currentRequest: ++currentRequest
        })
          .done(function( data ) {
            if (data.currentRequest !== String(currentRequest)) {
              console.log("Ignoring out of date response")
              return false; // we're out of date with the current filters.
            }
            $("#participants_table")
              .html(data.html.header)
              .append(data.html.records)

            display.update.navigation(data.navigation)
            display.update.selections()
            display.indicator('hide')
            init.stickyHeaders()
          })
      }
    }
    
    var selections = {
      objectIds: [],

      // Add a row to the "selected" set. You can provide an ID, an array of ID's, or an HTML element.
      add: function(element_or_id_or_ids, updateDisplay) {
        if ($.isNumeric(element_or_id_or_ids)) {
          selections.addId(element_or_id_or_ids)
        } else if ($.isArray(element_or_id_or_ids)) {
          selections.objectIds = element_or_id_or_ids.slice();
        } else {
          selections.add($(element_or_id_or_ids).data('participant-id'))
        }
        
        if (updateDisplay != false) display.update.selections();
        return selections.objectIds;
      },
      
      // Remove a row from the "selected" set. Similar to `select` method above.
      remove: function(element_or_id_or_ids, updateDisplay) {
        if ($.isNumeric(element_or_id_or_ids)) {
          selections.removeId(element_or_id_or_ids)
        } else if ($.isArray(element_or_id_or_ids)) {
          $.each(element_or_id_or_ids, function(index, value) {
            selections.remove(value)
          })
        } else {
          selections.remove($(element_or_id_or_ids).data('participant-id'))
        }

        if (updateDisplay != false) display.update.selections();
        return selections.objectIds;
      },
      
      addId: function(id) {
        if($.inArray(id, selections.objectIds) < 0)
          selections.objectIds.push(id)
        return selections.objectIds
      },
      
      removeId: function(id) {
        var pos = $.inArray(id, selections.objectIds)
        if(pos > -1)
          selections.objectIds.splice(pos, 1)
        return selections.objectIds
      },
      
      clear: function() {
        selections.objectIds = []
      },
      
      count: function() {
        return selections.objectIds.length
      }
      
    }
    
    var display = {
      currentPage: 1,
      totalPages: 1,
      
      // Update all the visual elements in the page that need to be changed.
      update: {
        
        all: function() {
          display.update.controls();
          display.update.count();
          display.update.clearLink();
          display.update.dropdowns();
          display.update.bucket();
          display.update.selections();
          // location hash
        },
      
        // Updates the display of the controls (the links that turn filters on and off).
        controls: function() {
          $("a.filter").each(function() {
            var id = $( this ).data("filter-id");
            var value = filters.get(id);
            $( this ).removeClass("text-success text-danger").find(".fa").removeClass("fa-check fa-ban")
            if(value == 'pass' || value == 'member') {
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
          $('.filtered_record_count').html(records.count + " of");
          $('header.sub .fa-filter').toggleClass("hidden", filters.isEmpty());
          display.update.emptyPlaceholder();
        },
        
        // Update everything related to selected objects
        selections: function() {
          display.update.hiddenSelectLink();
          display.update.selecteds();
        },
        
        // Updates the badge in the "Actions" menu and updates the "select all" link in that menu.
        hiddenSelectLink: function() {
          var hiddenNote = records.hiddenCount() > 0 ? ("(including " + records.hiddenCount() + " not visible)") : ""
          $('.bulk_actions li.select-all > a')
            .html("Select all " + records.objectIds.length + " records " + hiddenNote)
          
          if(selections.count() > 0) {
            $(".bulk_actions > button").attr("disabled", false)
            $("#bulk_actions_count").show().text(selections.count())
          } else {
            $(".bulk_actions > button").attr("disabled", true)
            $("#bulk_actions_count").hide()
          }
        },
        
        // For each currently selected object, toggle the on-screen check box appropriately.
        selecteds: function() {
          records.visible().each(function() {
            var participant_id = $( this ).data('participant-id')
            var shouldBeSelected = ($.inArray(participant_id, selections.objectIds) > -1)
            $( this ).find("td:first > input:checkbox").prop('checked', shouldBeSelected)
          })
        },
        
        // Updates the pagination controls based on the server's response.
        navigation: function(data) {
          $(".navigation-controls").toggleClass('hidden', data.total_pages <= 1)
          $(".navigation-controls .prev").toggleClass('hidden', data.current_page < 1)
          $(".navigation-controls .next").toggleClass('hidden', data.current_page >= data.total_pages)
          $(".navigation-controls .page-number").text(data.current_page)
          
          var elem = $(".navigation-controls ul.page-select").html("")
          for(var i = 1; i < data.total_pages; i++) {
            var li = $("<li>").html($("<a href='#'>").data('page', i).text(i))
            if (i == display.currentPage) li.addClass('active')
            elem.append(li)
          }
        },
        
        // Shows little tags for each set filter into the "filter bucket" at the top of the page.
        bucket: function() {
          $(".filter-bucket > li:not(.summary)").remove();
          $.each(filters.get(), function (key, value) {
            var newTag = $("<li />");
            if (value == "fail") {
              newTag
                .addClass("text-danger")
                .text($('[data-filter-id=\'' + key + '\'] > .filter-title').text())
                .prepend($("<i class='fa fa-ban fa-fw'></i>"))
            } else if (value == "pass") {
              newTag
                .addClass("text-success")
                .text($('[data-filter-id=\'' + key + '\'] > .filter-title').text())
                .prepend($("<i class='fa fa-check fa-fw'></i>"))
            } else {
              newTag
                .addClass("grouping")
                .text($('[data-filter-id=\'' + key + '\'] .selected-value').text())
                .prepend($("<i class='fa fa-group fa-fw'></i>"))
            }
            $(".filter-bucket").append(newTag);
          });
        },
        
        // Update the grouping dropdowns to show the current selections.
        dropdowns: function() {
          $(".filter-groupings > li[data-filter-id]").each(function(elem) {
            var value = filters.get($(this).data('filter-id'))
            $(this).find(".active").removeClass("active")
            var val_elem = $(this).find("[data-value='" + value + "']")
            val_elem.addClass("active")
            $(this).find(".selected-value").html(val_elem.text())
            $(this).toggleClass("filtered", $(this).find(".active").length > 0)
          })
        },
        
        // Update the current display of the grouping dropdowns
        groupings: function(data) {
          $(".filter-groupings > .dropdown").each(function() {
            var grouping = $(this).data('grouping')
            if (grouping && data[grouping].length > 0) {
              display.groupings.populate($(this), grouping, data)
              $(this).removeClass("hidden")
            } else {
              $(this).addClass("hidden")
            }
            display.groupings.toggleResetLinks($(this))
          })
        }
        
      },
      
      groupings: {
        
        // Populates the dropdowns for the groupings (cohort, high school, etc.).
        // If the server provides new values to include, this method will add them to
        // the appropriate dropdown.
        populate: function(elem, grouping, data) {
          var menu_elem = elem.find('.dropdown-menu')
          $.each(data[grouping], function(index, item) {
            var li = menu_elem.find("li[data-value='" + item.value + "']")
            if (li.length < 1) {
              li = menu_elem.find("li.template").clone().removeClass('hidden template')
              li.attr('data-value', item.value)
              li.find('.filter-title').html(item.title)
              li.appendTo(menu_elem)
            } else {
              li.removeClass('disabled')
            }
          });
        },
        
        // Based on the current selected values, toggles the appearance of the "show all"
        // option in each dropdown menu.
        toggleResetLinks: function(elem) {
          elem.find('.any,.divider').toggleClass('hidden', elem.find('.active').length < 1)
        }
        
      },
      
      // Shows or hides the loading indicator.
      indicator: function(command) {
        $(".indicator.participants").toggleClass("hidden", command == 'hide')
      },
      
      // Returns the currently selected report type.
      reportType: function() {
        return $(".report-select .active [data-report]").data('report')
      },
      
      navigation: {
        
        nextPage: function() {
          display.navigation.goToPage(display.currentPage + 1)
        },
        
        prevPage: function() {
          display.navigation.goToPage(display.currentPage - 1)
        },
        
        goToPage: function(newPage) {
          display.indicator('show')
          display.currentPage = newPage
          records.fetchFromServer()
        }
        
      }
      
    }
    
    return {
      initialize: function(_selector) {
        selector = _selector;
        init.bindEvents();
      },
      init: init,
      filters: filters,
      display: display,
      records: records,
      selections: selections
    }
  })();
  
}).call(this);

$(function() {
  App.filterable.initialize(".filterable")
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
