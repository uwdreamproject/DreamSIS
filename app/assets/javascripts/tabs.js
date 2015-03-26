$(function() {
  if($('ul.tabs').length > 0) {
    bindKeyboardShortcutsForTabs();
    switchToHashTab();
  }
});

// Binds the event handlers for the up and down keys to switch betwen tabs.
function bindKeyboardShortcutsForTabs() {
  $( document ).keydown(function (event) {
    if($(document.activeElement).is('textarea,input,select')) { return; }
    switch (event.which) {
    case $.ui.keyCode.DOWN:
      event.preventDefault();
      nextTab();
      break;
    case $.ui.keyCode.UP:
      event.preventDefault();
      previousTab();
      break;
    default: return;
    }
  });
}

// Moves to a particular tab
function switchToTab(tab_id, object_id, extra_params) {
  $('.info-section-container .active').removeClass('active')
  $('.info-section#' + tab_id).addClass('active');
  $('#' + tab_id + '_tab_link').addClass('active');
  var new_hash = "!/section/" + tab_id

  // Handle extra params
  if(extra_params) {
    if(extra_params == "show=needs_followup") {
      toggleFollowupNotes()
      new_hash += "&" + extra_params
    }
  }

  // Scroll to the selected element, if provided
  if(object_id) {
    var obj = $(".info-section#" + tab_id + " [id*=" + object_id + "]")
    scrollToObject(obj)
  } else {
    $("html, body").animate({ scrollTop: 0 }, "slow");    
  }
  
  // Update the url hash
  window.location.hash = new_hash
}

// Switches to the tab specified in the URL hash
function switchToHashTab() {
  var tabHashMatch = decodeURIComponent(window.location.hash).match(/#!\/section\/(\w+)\/?(\d+)?&?(\w+=\w+)*/)
  if(tabHashMatch && tabHashMatch[1]) {
  	switchToTab(tabHashMatch[1], tabHashMatch[2], tabHashMatch[3]);
  }
}

// Switch to the "next" tab
function nextTab() {
  var next_li = $('ul.tabs .active').first().parent('li').next()
  if(next_li.length === 0) {
    return false
  } else {
    var next_tab = next_li.children('a').first()
    switchToTab(next_tab.attr('id').replace("_tab_link", ""))
  }
}

// Switch to the "previous" tab
function previousTab() {
  var previous_li = $('ul.tabs .active').first().parent('li').prev()
  if(previous_li.length === 0) {
    return false
  } else {
    var previous_tab = previous_li.children('a').first()
    switchToTab(previous_tab.attr('id').replace("_tab_link", ""))
  }
}

function toggleFollowupNotes() {
    $(".notes blockquote:not(.needs-followup)").toggleClass("hidden")
    $(".notes .date-interval").toggleClass("hidden")
    $(".show_all_notes").toggle()
}