// If a document defines the attendanceEventIds variable, automatic attendance handling will turn on.
$(document).ready( function() {
  if (typeof attendanceEventIds !== 'undefined') {
    buildAttendanceTable(attendanceEventIds)
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
      data.name + "<br>" + data.date
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

  // Always add the event attendance ID
  elem.attr("data-event-attendance-id", (attendanceData ? attendanceData.id : undefined))

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
    var wrap = $( "<span>", { "class": "emwrap" })
    currentOption = attendanceData == null ? "" : (attendanceData.attendance_option || "")
    wrap.append( $( "<strong>" ).html( currentOption[0] ) )
    wrap.append( $( "<em>" ).addClass("value").html( currentOption ) )
    elem.addClass("optioned").html( wrap )
    var attendanceOptions = attendanceOptionsFor(elem)
    var i = attendanceOptions.indexOf(currentOption)    
    colorizeAttendanceOption(elem, i, attendanceOptions.length)
    elem.click( function(e) {
      nextAttendanceOption($( this ))
      submitAttendance($( this ), eventId, {
        person_id: $( this ).parents("tr").data("participant-id"),
        attended: $( this ).data("attended"),
        attendance_option: $( this ).find("em.value").html()
      })
      e.stopImmediatePropagation()
    })
  }
}

/*
  Sends the request to actually update the attendance record. If the DOM element has
  an event-attendance-id attribute assigned, then we submit the request as an UPDATE,
  otherwise, use a CREATE and update the id attribute from the returned payload.
*/
function submitAttendance(elem, eventId, data) {
  var url = "/events/" + eventId + "/event_attendances/"
  var event_attendance_id = elem.data("event-attendance-id")
  var method;
  if (event_attendance_id !== undefined) {
    url += event_attendance_id
    method = "PUT"
  } else {
    method = "POST"
  }
  $.ajax({
    type: method,
    url: url,
    data: { "event_attendance": data },
    success: function(returnData, textStatus, jqXHR) {
      if(elem.data("event-attendance-id") == undefined) {
        elem.attr("data-event-attendance-id", returnData.id)
      }
    },
    dataType: 'json' });
}

/*
  Change this element to the next attendance option in the list, or loop back to blank.
*/
function nextAttendanceOption(elem) {
  var currentValue = elem.find("em").html()
  var attendanceOptions = attendanceOptionsFor(elem)
  var i = attendanceOptions.indexOf(currentValue)
  if (i == attendanceOptions.length-1) {
    elem.find("strong").html("")
    elem.find("em.value").html("")
    elem.attr("data-attended", false)
    i = -1
  } else {
    i = i+1
    var nextValue = attendanceOptions[i]
    elem.find("strong").html( nextValue[0] )
    elem.find("em.value").html( nextValue )
    elem.attr("data-attended", true)
  }
  colorizeAttendanceOption(elem, i, attendanceOptions.length)
}

/*
  Returns the attendance options for the requested table cell, which are stored in the 
  corresponding column's header th.
*/
function attendanceOptionsFor(tdElem) {
  var options = $("th[data-column-id=" + tdElem.data("column-id") + "]").data("attendance-options")
  return (options || [])
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