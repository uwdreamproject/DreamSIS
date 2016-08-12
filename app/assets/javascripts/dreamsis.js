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
$( function() {
  $(".bulk_actions a").click(function() {
    var url = $(this).data("original-href") + "?" + selectedElements().serialize() + "&" + $(this).data("extra-params")
    $( this ).attr("href", url)
  })
})

// Returns the currently selected rows
function selectedElements() {
	return $('tbody:not(.hidden) input.index_check_box:checked')
}

// Shows the actions that can be performed, if any rows are selected.
function updateWithSelectedActions() {
	if($(".bulk_actions")) {
		if(selectedElements().length > 0) {
			$(".bulk_actions").show()
			$("#bulk_actions_count").text(selectedElements().length)
		} else {
			$(".bulk_actions").hide()
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

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover()
})
