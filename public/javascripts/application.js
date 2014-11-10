/*
 *
 *
  THIS IS NOW SUPERCEDED BY /app/assets/javascripts/dreamsis.js
 *
 *
*/


var checkXlsxStatus = false;
var showAjaxIndicator = true;
var loadCount = 0;

var responder = {
	onCreate: function() {
		if (Ajax.activeRequestCount > 0) {
      if (showAjaxIndicator)
		    $('indicator').addClassName("visible")
      showAjaxIndicator = true;
    }
	},
	onException: function(request, exception) {
		$('indicator').removeClassName("visible")
    if(exception.message != "'undefined' is not an object (evaluating 'entry.autocompleteIndex = i')")
      updateFlashes( { "error" : "There was a problem processing your request. Your data was not saved." })
    console.log(exception)
	},
	onComplete: function(event, request) {	
		if (Ajax.activeRequestCount == 0)
			$('indicator').removeClassName("visible")
		
		// Update the flash messages
		if (request.status == 500) {
			updateFlashes({ "error" : "The server encountered a fatal error processing your request." })
		} else {
			clearFlashes()
			var flash = request.getResponseHeader('X-Flash-Messages').evalJSON();
			if(!flash) return;
			updateFlashes(flash)
		}
	}
}

Ajax.Responders.register(responder);

document.observe("dom:loaded", function() {
  Event.observe(window, "scroll", function() { 
    if ( $('body').scrollTop > $('header').getHeight() ){
      $('body').addClassName('scrolled-past-header');
    } else {
      $('body').removeClassName('scrolled-past-header');
      var newtop = $('header').getHeight() - $('body').scrollTop
      $('sidebar').setStyle({ top: newtop + 'px' });
    }
  });
});

function clearFlashes() {
	$('notice_notification').removeClassName('visible')
	$('error_notification').removeClassName('visible')
	$('info_notification').removeClassName('visible')
	$('saved_notification').removeClassName('visible')
	
	// Wait for a second to clear the text, if it's hidden.
	setTimeout(function() {
		if(!$('notice_notification').hasClassName('visible')) $('notice_notification').innerHTML = ''
		if(!$('error_notification').hasClassName('visible')) $('error_notification').innerHTML = ''
		if(!$('info_notification').hasClassName('visible')) $('info_notification').innerHTML = ''
		if(!$('saved_notification').hasClassName('visible')) $('saved_notification').innerHTML = ''
	}, 1000)
}

function updateFlashes(flash) {
	if(flash.notice) { $('notice_notification').innerHTML = flash.notice; $('notice_notification').addClassName('visible') }
	if(flash.error) { $('error_notification').innerHTML = flash.error; $('error_notification').addClassName('visible') }
	if(flash.info) { $('info_notification').innerHTML = flash.info; $('info_notification').addClassName('visible') }
	if(flash.saved) { $('saved_notification').innerHTML = flash.saved; $('saved_notification').addClassName('visible') }
}

// Handles filtering lists in place
function initFilters(filter_keys) {
	filters = new Hash;  // filters are the things to filter on, like status and assigned_to
	filterables = new Hash;  // filterables are the items to filter, like table rows or list items
	appliedFilters = new Hash;  // applied filters is a snapshot of the current state of all the filters
	filter_keys.each(function(f) { filters.set(f, new Array) });
	filter_keys.each(function(f) { filterables.set(f, new Hash) });
	filter_keys.each(function(f) { appliedFilters.set(f, new Array) });
}

// Adds a key to the list of filters
function addToFilter(filter_key, value) {
	filters.get(filter_key).push(value)
	appliedFilters.get(filter_key).push(value)
}

// Adds a filterable item
// The filterables hash looks like:
//    assigned_to (hash key)
//        - 3103 (hash value -> array)
//             - object
//             - object
//        - 144 (hash value -> array)
//             - object
//             - object
function filterable(obj_id, filter_key, value) {
	if (typeof(filterables) === "undefined") {
		return false
	}
	h = filterables.get(filter_key)
	if (h.get(value) == undefined) {
		h.set(value, new Array)
	}
	h.get(value).push($(obj_id))
}

function changeFilter(obj_dom_id, filter_key, value) {
	element = $(obj_dom_id)
	// window.console.log("changeFilter: obj_dom_id: " + obj_dom_id + " -- checked?: " + element.checked + " -- filter_key: " + filter_key + "-- value: " + value)
	if (element.checked) {
		// appliedFilters.get(filter_key).push(value)
		appliedFilters.set(filter_key, true)
	} else {
		// appliedFilters.set(filter_key, appliedFilters.get(filter_key).without(value))
		appliedFilters.set(filter_key, false)
	}
	executeFilters();
}

// Executes the filter on the filterables, taking into account all of the filters that have been applied or not.
function executeFilters() {
	// window.console.log("   Executing filters")
	showAllFilterables();
	filterables.each(function(pair) {
		filter_key = pair.key
		elements = pair.value.get(false)
		if (appliedFilters.get(filter_key) == true && elements) {
			// window.console.log("   Filter " + filter_key + ": Hiding " + filter_key + "/false (" + elements.size() + " elements)")
			// elements.invoke('hide')
			elements.invoke('addClassName', 'hidden')
		} else if (elements) {
			// window.console.log("   Filter " + filter_key + ": Keeping " + filter_key + "/true visible (" + elements.size() + " elements)")
		} else {
			// window.console.log("   Filter " + filter_key + ": No elements to filter for " + filter_key)
		}
	})
	updateRecordCount();
}

// shows all the filterable items to give us a clean slate before running executeFilters()
function showAllFilterables() {
	// window.console.log("   Showing all filterables")
	filterables.each(function(filter_keys) {
		filter_keys.value.each(function(elements) {
			// elements.value.invoke('show')
			elements.value.invoke('removeClassName', 'hidden')
		})
	})
}

// Adds the "preview_filter" CSS class to the filter elements but doesn't hide them
function previewFilter(filter_key) {
	elements = filterables.get(filter_key).get(true)
	elements.invoke('addClassName', 'preview')
}

function unpreviewFilter(filter_key) {
	elements = filterables.get(filter_key).get(true)
	elements.invoke('removeClassName', 'preview')
}

// Shows everything and unchecks all the checkboxes
function clearAllFilters() {
	showAllFilterables()
	$$('.filter_checkbox').each(function(e) {e.checked = false}) // uncheck all the boxes to start
	updateRecordCount()
}

// Tries to update a div with id "filtered_record_count" with the number of filterables that are visible.
// Or, specify a filter_key to only return the number for that filter_key.
function updateRecordCount(filter_key) {
	// window.console.log("updateRecordCount(" + filter_key + ")")
	if (filter_key) {
		if ($('record_count_' + filter_key)) {
			filterables_count = filterables.get(filter_key).get(true)
			filterables_count = filterables_count == undefined ? "0" : filterables_count.size()
			$('record_count_' + filter_key).update(filterables_count)
		}
	} else {		
		if ($('filtered_record_count')) {
			$('filtered_record_count').update($$('.filterable:not(.hidden)').size() + " of")
			updateWithSelectedActions()
		}
		filterables.each(function(pair) {
			filter_key = pair.key
			updateRecordCount(filter_key)
		})
	}
}

// Sets a filter using some shortcuts and then executes the new filter. Valid options for 'type' are:
// 	'only'	- shows just the value that's passed
// 	'all'	- shows all filterables in this category
// 	'none'	- shows none of the filterables in this category (this is the default)
function setFilter(type, filter_key, value) {
	value += ''	// convert int to string
	if (filter_key === undefined) {
		filter_key = ''
	}
	// appliedFilters.get(filter_key).clear() // filter everything to start
	$$('.' + filter_key + '_filter_checkbox').each(function(e) {e.checked = false}) // uncheck all the boxes to start
	if (type == 'only') {
		// appliedFilters.get(filter_key).push(value)
		appliedFilters.set(filter_key, value)
		dom_id = "filter_" + filter_key + "_" + value
		$(dom_id).checked = true
	}
	if (type == 'all') {
		appliedFilters.set(filter_key, filters.get(filter_key).clone())
		$$('.' + filter_key + '_filter_checkbox').each(function(e) {e.checked = true})
	}
	executeFilters();
}

// Returns the currently selected rows
function selectedElements() {
	return $$('tbody:not(.hidden) input.index_check_box:checked')
}

// Shows the actions that can be performed, if any rows are selected.
function updateWithSelectedActions() {
	if($("with_selected_actions")) {
		if(selectedElements().length > 0) {
			$("with_selected_actions").show()
			$("with_selected_actions_count").update(selectedElements().length)
		} else {
			$("with_selected_actions").hide()
		}
	}
}

// For merging records on an index screen.
function addMergeTarget(element) {
	if($('merge_form') && $('merge_form').visible()) {
		if($F('merge_source_id') == '') {
			selectMergeItem(element, "source")
		} else if($F('merge_target_id') != '') {
			selectMergeItem(element, "source")
			selectMergeItem(null, "target")
		} else {
			selectMergeItem(element, "target")
		}
	}
}

function selectMergeItem(element, part) {
	if(element == null) {
		$('merge_' + part + '_id').value = ''
		$('merge_' + part + '_name').update('(Not selected)')
		$$('.merge_' + part).invoke('removeClassName', 'merge_' + part)
	} else {
		$('merge_' + part + '_id').value = element.getAttribute('data-id')
		$('merge_' + part + '_name').update(element.down('.name').innerHTML)
		$$('.merge_' + part).invoke('removeClassName', 'merge_' + part)
		element.addClassName('merge_' + part)
	}
}




function setToNow(element_id) {
	d = new Date()
  if($(element_id + '_1i')) $(element_id + '_1i').value = d.getFullYear()
  if($(element_id + '_2i')) $(element_id + '_2i').value = d.getMonth() + 1
 	if($(element_id + '_3i')) $(element_id + '_3i').value = d.getDate()
  if($(element_id + '_4i')) $(element_id + '_4i').value = pad(d.getHours(), 2, "0")
  if($(element_id + '_5i'))$(element_id + '_5i').value = pad(d.getMinutes(), 2, "0")
}

function setToClear(element_id) {
  if($(element_id + '_1i')) $(element_id + '_1i').value = ""
  if($(element_id + '_2i')) $(element_id + '_2i').value = ""
 	if($(element_id + '_3i')) $(element_id + '_3i').value = ""
  if($(element_id + '_4i')) $(element_id + '_4i').value = ""
  if($(element_id + '_5i'))$(element_id + '_5i').value = ""
}

/*
	Filters a list of location items by county. Add a class name of "filterable-by-county" for all 
	filterable elements, and a class of "county-{value}" to define which county the element is in.
*/
function filterByCounty(filter_value) {
	if(filter_value == 'reset') { 
		$$('.filterable-by-county').invoke('show');
		window.location.hash = ""
	} else { 
		$$('.filterable-by-county').invoke('hide'); 
		$$('.filterable-by-county.county-' + filter_value).invoke('show') 
		window.location.hash = "filter-county=" + filter_value
	}
}

// Used for activity logs.
function updateActivityTimeDescription(elem) {
	values = new Array("", "Some", "Lots", "Nearly all")
	elem.next("span.value").update(values[elem.value])
	elem.up("li").removeClassName("time0").removeClassName("time1").removeClassName("time2").removeClassName("time3")
	elem.up("li").addClassName("time" + elem.value)
}

// Left-pads a string with the specified character.
function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

// Averages the numbers in an array.
function average(numbers) {
	var total = 0.0;
	for (var i=0; i < numbers.length; i++) {
		total += numbers[i];
	}
	return total / numbers.length;
}

// Averages the numbers in an array and rounds to the nearest whole number.
function average_and_round(numbers) {
	var averaged = average(numbers);
  return Math.round(averaged);
}

// Sums the numbers in an array.
function sum(numbers) {
	var total = 0.0;
	for (var i=0; i < numbers.length; i++) {
		total += numbers[i];
	}
	return total;
}

// Moves to a particular tab
function switchToTab(tab_id) {
  $$('.info-section-container .active').each(function(n) { n.removeClassName('active') })
  $(tab_id).addClassName('active');
  $(tab_id + '_tab_link').addClassName('active');
  window.location.hash = tab_id
}

// Switch to the "next" tab
function nextTab() {
  var next_li = $$('ul.tabs .active').first().up('li').next()
  if(! next_li) {
    return false
  } else {
    var next_tab = next_li.down('a')
    switchToTab(next_tab.id.gsub("_tab_link", ""))
  }
}

// Switch to the "previous" tab
function previousTab() {
  var previous_li = $$('ul.tabs .active').first().up('li').previous()
  if(! previous_li) {
    return false
  } else {
    var previous_tab = previous_li.down('a')
    switchToTab(previous_tab.id.gsub("_tab_link", ""))
  }
}
