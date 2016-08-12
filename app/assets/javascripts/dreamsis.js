var checkExportStatus = false;
var showAjaxIndicator = true;
var loadCount = 0;
var debug = false;

// Scrolls the page to the provided element
function scrollToObject(jqObj) {
  $("html, body").animate(
    { scrollTop: jqObj.offset().top - 20 }, "slow"
  );
}


// Prep the bulk actions links to incorporate the currently selected rows with javascript.
// $(document).on("click", ".bulk_actions a", function() {
//   var url = $(this).data("original-href") + "?" + selectedElements().serialize() + "&" + $(this).data("extra-params")
//   $( this ).attr("href", url)
// })

// Returns the currently selected rows
function selectedElements() {
	return $('tbody:not(.hidden) input.index_check_box:checked')
}

// Shows the actions that can be performed, if any rows are selected.
function updateWithSelectedActions() {
	if($(".bulk_actions")) {
		if(selectedElements().length > 0) {
			$(".bulk_actions > button").attr("disabled", false)
			$("#bulk_actions_count").show().text(selectedElements().length)
		} else {
			$(".bulk_actions > button").attr("disabled", true)
      $("#bulk_actions_count").hide()
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
		$$('.merge_' + part).invoke('removeClass', 'merge_' + part)
	} else {
		$('merge_' + part + '_id').value = element.getAttribute('data-id')
		$('merge_' + part + '_name').update(element.down('.name').innerHTML)
		$$('.merge_' + part).invoke('removeClass', 'merge_' + part)
		element.addClass('merge_' + part)
	}
}

$(function() {
  registerDateInputHelpers();
})

function registerDateInputHelpers() {
  $('.link-to-now').click(function(event) {
    setToNow($(event.target).data('target'))
    event.preventDefault();
  })
  $('.link-to-clear').click(function(event) {
    setToClear($(event.target).data('target'))
    event.preventDefault();
  })
  
  $('input[type=datetime-local]').datepicker({
      format: "yyyy-mm-dd 00:00:00",
      todayBtn: "linked",
      todayHighlight: true,
      disableTouchKeyboard: true,
      autoclose: true
  });
  
  $('input[type=date]').datepicker({
      format: "yyyy-mm-dd",
      todayBtn: "linked",
      todayHighlight: true,
      disableTouchKeyboard: true,
      autoclose: true
  });
  
}

function setToNow(element_id) {
	d = new Date()
  if($('#' + element_id + '_1i')) $('#' + element_id + '_1i').val(d.getFullYear())
  if($('#' + element_id + '_2i')) $('#' + element_id + '_2i').val(d.getMonth() + 1)
 	if($('#' + element_id + '_3i')) $('#' + element_id + '_3i').val(d.getDate())
  if($('#' + element_id + '_4i')) $('#' + element_id + '_4i').val(pad(d.getHours(), 2, "0"))
  if($('#' + element_id + '_5i')) $('#' + element_id + '_5i').val(pad(d.getMinutes(), 2, "0"))
}

function setToClear(element_id) {
  if($('#' + element_id + '_1i')) $('#' + element_id + '_1i').val("")
  if($('#' + element_id + '_2i')) $('#' + element_id + '_2i').val("")
 	if($('#' + element_id + '_3i')) $('#' + element_id + '_3i').val("")
  if($('#' + element_id + '_4i')) $('#' + element_id + '_4i').val("")
  if($('#' + element_id + '_5i')) $('#' + element_id + '_5i').val("")
}

// Used for activity logs.
function updateActivityTimeDescription(elem) {
	values = new Array("", "Some", "Lots", "Nearly all");
	elem.next("span.value").html(values[elem.val()]);
	elem.parent("li").removeClass("time0").removeClass("time1").removeClass("time2").removeClass("time3");
	elem.parent("li").addClass("time" + elem.val());
}

function registerTableSorters() {
  return false
  //
  //
  //
  $("th.functions").addClass("sorter-false")
  $(":not(.calendar) > table:not(.no-sort)").tablesorter({ theme: "dreamsis", sortStable: true })

  $("table.object_filters > tbody").sortable({
    axis: 'y',
    cursor: 'move',
    handle: '.handle',
    update: function(elem) {
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
    }
  })
}

/*
  Global Functions
*/
$( function() {
  
  // A form element with .submit-on-change will submit the enclosing form when changed.
  $(".submit-on-change").change( function() {
    $( this ).parents("form").submit()
  })
  
  // A form element with .send-on-change and a data-url attribute will send that data to the url.
  $(".send-on-change").change( function() {
    $.post(
      $( this ).attr('data-url'),
      $( this ).serialize()
    );
  })
  
  // Prep the taggable fields
  $('select.taggable').each(function() {
      $(this).select2({
          minimumResultsForSearch: Infinity,
          placeholder: "Assign tags"
      });
  });
  
  $("a[data-submit]").on('click', function(event) {
    event.preventDefault();
    var f = $( this ).data('submit') == "main" ? $("#main-content form").first() : $( this ).closest('form');
    f.submit();
  })

  
  // Enable all tablesorter tables
  registerTableSorters()


  $(document).on("click", "input:checkbox.select-all", function() {
    var currentState = $( this ).prop("checked")
    $('input.index_check_box').prop("checked", currentState)
    updateWithSelectedActions()
  })
  
  
})

// Enable our popovers using event delegation so that they will work with dynamic elements.
$(document).popover({
  selector: '[data-toggle="popover"]',
  trigger: 'focus'
})

$(document).on('click', '[data-toggle="popover"]', function(event) {
  event.preventDefault();
})

// Bind the popover events so we can perform async methods. To use this feature,
// provide a `data-url` on the element and a `data-function` that refers to one
// of the functions in popovers.js.
$(document).on('inserted.bs.popover', function(event) {
  var elem = $(event.target),
      po = elem.data('bs.popover'),
      tip = po.tip(),
      content = tip.find('.popover-content');
      
  if (elem.hasClass('loaded')) return;
  
  if (elem.data('url')) {
    $('.indicator.global').clone().removeClass('global hidden').appendTo(content)
    $.get(elem.data('url'))
      .done(function(data) {
        po.options.html = true
        po.options.content = popovers.functions[elem.data('function')](data)
        elem.addClass('loaded').popover('show')
      })
  }
})
