// Moves to a particular tab
function switchToTab(tab_id) {
  $('.info-section-container .active').removeClass('active')
  $('.info-section#' + tab_id).addClass('active');
  $('#' + tab_id + '_tab_link').addClass('active');
  window.location.hash = "!/section/" + tab_id
  $("html, body").animate({ scrollTop: 0 }, "slow");
}

// Switches to the tab specified in the URL hash
function switchToHashTab() {
  var tabHashMatch = window.location.hash.match(/#!\/section\/(\w+)/)
  if(tabHashMatch && tabHashMatch[1]) {
  	switchToTab(tabHashMatch[1]);
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