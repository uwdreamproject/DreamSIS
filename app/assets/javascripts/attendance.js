// If a document defines the attendanceEventIds variable, automatic attendance handling will turn on.
$(document).ready( function() {
  if (typeof attendanceEventIds !== 'undefined') {
    buildAttendanceTable(attendanceEventIds)
  }
  
  if ( typeof attendancePersonId !== 'undefined' && $(".attendance.mini .attendance-day[data-date]")) {
    populateMiniAttendanceTable()
  }
})

/*
  Triggers everything by building the attendance table that needs to have been scaffolded in the html.
*/
function buildAttendanceTable(attendanceEventIds) {
  $.each(attendanceEventIds, function(index, eventId) {
    addAttendanceColumn(eventId, index + 1)
  })
}

/*
  Take a pre-existing mini attendance table and turn the relevant dates into attendance checkboxes.
*/
function populateMiniAttendanceTable() {
  var dates = $('.attendance.mini .current-month .attendance-day[data-date]').map(function(e) { 
    return $(this).data("date") }
  ).get()
  $(".attendance.mini tr").attr("data-participant-id", attendancePersonId)
  lookupAttendanceEventsByDate(dates)
}

/*
  Populate all of the cells in the column specified by columnId using the
information about the event specified by eventId. Event info is first fetched with a
JSON request to the Events controller, and then each person row is populated appropriately.
*/
function addAttendanceColumn(eventId, columnId) {
  // Fetch and populate the event header
  url = "/events/" + eventId + ".json"
  var attendanceOptions = []
  $.getJSON( url, function( data ) {
    // console.log(data)
    $('.attendance-matrix thead th[data-column-id=' + columnId + ']').html( 
      (data.name || "") + "<br>" + data.date
    ).data("attendance-options", data.attendance_options)
    
    // Fetch and populate the attendee rows
    url = "/events/" + eventId + "/event_attendances.json"
    $.getJSON( url, function( data ) {
      $.each( data, function( key, value ) {
        elem = $(".attendance-matrix tbody tr[data-participant-id='" + value.person_id + "'] td[data-column-id='" + columnId + "']")
        attendanceCheckbox(elem, eventId, value)
      })
    });

    // Populate the empty rows
    $(".attendance-matrix tbody tr[data-participant-id] td[data-column-id='" + columnId + "']:empty").each( function(index, elem) {
      attendanceCheckbox($( this ), eventId, null)
    });
  })
}

/*
  Populate the specified element with the appropriate attendance "checkbox." For events
that support attendance options, this doesn't actually print a checkbox but rather a specially
crafted <span> that allows the user to cycle through the options. Regardless of what is rendered,
it attaches the appropriate click handler to submit the new data every time.
*/
function attendanceCheckbox(elem, eventId, attendanceData) {

  // Always add the event attendance ID and event ID
  elem.attr("data-event-attendance-id", (attendanceData ? attendanceData.id : undefined))
  elem.attr("data-event-id", eventId)

  // Show a normal checkbox
  if (attendanceOptionsFor(elem).length == 0) {
    var wrap = $( "<input />" ).attr( "type", "checkbox" ).change( function() {
      submitAttendance($( this ), eventId, {
        person_id: $( this ).parents("tr").data("participant-id"),
        attended: $( this ).prop("checked")
      })
    })
    elem.addClass("centered").removeClass("optioned").html( wrap )
    
  // Show a Multi-option selector instead
  } else {  
    var container = $( "<div>", { "class": "select-container" } )
    // Allow touchscreens to select the "pseudo-checkbox"
    container.attr("tabIndex", 0)
    // But "unselect" a box when the mouse moves to a different element
    elem.mouseout(function() { container.blur() })

    var wrap = $( "<span>", { "class": "emwrap" })
    currentOption = attendanceData == null ? "" : (attendanceData.attendance_option || "")
    wrap.append( $( "<strong>" ).html( currentOption[0] ) )
    container.append(wrap)
    elem.addClass("optioned").html( container )
    var attendanceOptions = attendanceOptionsFor(elem)
    var i = attendanceOptions.indexOf(currentOption)    
    colorizeAttendanceOption(elem, i, attendanceOptions.length)

    var choices = $( "<div>", { "class": "choice-dropdown" } )
    container.append(choices)

    for (var j = 0; j < attendanceOptions.length; j++) {
      var option = attendanceOptions[j]
      var selector = $( "<span>", {"class": "choice" } )
      choices.append(selector)
      selector.text(option)
      setAttendanceOption(selector)
      if (i == j) { selector.addClass("selected") }
      selector.click( function(e) {
        submitAttendance($( this ), eventId, {
          person_id: $( this ).parents("tr").data("participant-id"),
          attended: $( this ).attr("data-attended"),
          attendance_option: $( this ).text()
        })
        e.stopImmediatePropagation()
      })
    }

    var clearSelector = $( "<span>", {"class": "choice clear"} )
    choices.append(clearSelector)
    clearSelector.text("Clear")
    clearSelector.attr("data-attended", null);
    clearSelector.click( function(e) {
      submitAttendance($( this ), eventId, {
        person_id: $( this ).parents("tr").data("participant-id"),
        attended: null,
        attendance_option: ""
      })
      e.stopImmediatePropagation()
    })
  }
}

/*
  Sends the request to actually create or update the attendance record.
*/
function submitAttendance(elem, eventId, data) {
  var url = "/events/" + eventId + "/event_attendances/"
  clearFlashes()
  elem.addClass("saving")
  elem.attr("data-expected-attendance-option", data.attendance_option) // store the value to check before clearing the spinner
  var parentOptioned = elem.parents(".optioned")
  var choiceDropdown = parentOptioned.find(".choice-dropdown")

  // Overlay the selectors with a translucent div to deter concurrent updates for the same EventAttendance
  choiceDropdown.append($( "<div>", { "id" : "disable-blur" } ))

  $.ajax({
    type: 'POST',
    url: url,
    data: { "event_attendance": data },
    success: function(returnData, textStatus, jqXHR) {
      if(elem.data("event-attendance-id") == undefined) {
        elem.attr("data-event-attendance-id", returnData.id)
      }
      // console.log("Expected: `" + elem.attr("data-expected-attendance-option") + "`, received: `" + returnData.attendance_option + "`")
      if(returnData.attendance_option == elem.attr("data-expected-attendance-option")){
        elem.removeClass("saving") // only remove the spinner if the attendance option matches, to prevent "quick click" overrides

        // Update the styling of the relevant selectors and checkbox
        var attendanceOptions = attendanceOptionsFor(parentOptioned)
        var i = attendanceOptions.indexOf(returnData.attendance_option)
        colorizeAttendanceOption(parentOptioned, i, attendanceOptions.length)
        var childStrong = parentOptioned.find("strong")
        childStrong.text(returnData.attendance_option[0] || "")
        parentOptioned.find(".choice").removeClass("selected")
        elem.addClass("selected")
      }
    },
    complete: function() {
      $("#disable-blur").remove()
    },
    dataType: 'json' });
}

/*
  Set the attendance option to be sent with an ajax request, and color the element
  appropriately.
*/
function setAttendanceOption(elem) {
  var currentValue = elem.text()
  var attendanceOptions = attendanceOptionsFor(elem.parents(".optioned"))
  var i = attendanceOptions.indexOf(currentValue)
  if (i == attendanceOptions.length-1) {
    elem.attr("data-attended", false)
  } else {
    elem.attr("data-attended", true)
  }
  colorizeAttendanceOption(elem, i, attendanceOptions.length)
}

/*
  Returns the attendance options for the requested table cell, which are stored in the 
  corresponding column's header th.
*/
function attendanceOptionsFor(tdElem) {
  if (tdElem.data("attendance-options")) {
    return tdElem.data("attendance-options")
  } else {
    var options = $("th[data-column-id=" + tdElem.data("column-id") + "]").data("attendance-options")
    return (options || [])
  }
}

/*
  Set the appropriate class for the element based on the index of the attendance option set.
*/
function colorizeAttendanceOption(elem, index, max) {
  klass = 'none';
  switch(index) {
	  case -1:
		  klass = 'none';
		  break;
	  case 0:
		  klass = 'first';
		  break;
	  case max-1:
		  klass = 'last';
		  break;
	  default: 
      klass = 'middle';
  }
  
  elem.removeClass("first").removeClass("middle").removeClass("last").addClass(klass)
}

/*
  Lookup the event info for a set of requested dates.
*/
function lookupAttendanceEventsByDate(datesArray) {
  var url = "/events.json"
  var params = { dates: datesArray, type: "Visit" }
  $.getJSON( url, params, function( eventsData ) {

    // Fetch the attendance data for this person
    var url = "/participants/" + attendancePersonId + "/event_attendances.json"
    var params = { dates: datesArray, type: "Visit" }
    $.getJSON( url, params, function( attendanceData ) {

      // Populate the empty rows
      $.each( eventsData, function( date, value ) {
        var elem = $(".attendance.mini .current-month .attendance-day[data-date='" + date + "']")
        if ( elem )
          elem.data("attendance-options", value[0].attendance_options)
          attendanceCheckbox(elem, value[0].id, null)
          // elem.children(".emwrap").children("strong").text(
          //   (new Date(date)).getDay()
          // ).css("font-weight", "normal")
          addDetailToAttendanceCheckbox(elem, value[0])
      })
      
      // For each event attendance make a checkbox
      $.each( attendanceData, function( date, value ) {
        elem = $(".attendance.mini .current-month .attendance-day[data-date='" + date + "']")
        attendanceCheckbox(elem, value[0].event_id, value[0])
        addDetailToAttendanceCheckbox(elem, value[0].event)
      })
      
    });
    
  })
}

function addDetailToAttendanceCheckbox(elem, eventData) {
  d = new Date(eventData.date)
  $("<div />").addClass("details").addClass("arrow-box bottom").append(
    d.getUTCDate() + " " + 
    ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][d.getUTCMonth()] + " " + 
    d.getUTCFullYear()
  ).append(
    $("<br /><strong />").text(eventData.name)
  ).appendTo(elem)  
}
