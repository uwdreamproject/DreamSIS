// If a document defines the checkExportStatusUrl variable, automatic report checking will turn on.
$(document).ready( function() {
  if (typeof checkExportStatusUrl !== 'undefined') {
    exportStatusWorker();
    setInterval('exportStatusWorker()', 3000);
  }
})

// Setup the export status checker, which will be called with setInterval.
function exportStatusWorker() {
  if (checkExportStatus == true && typeof(exportReportId) !== 'undefined') {
    urlToCheck = checkExportStatusUrl.replace("__id__", exportReportId);
    if (debug) console.log("[exportStatusWorker] checkExportStatus: " + checkExportStatus + ", urlToCheck: " + urlToCheck)
		$.ajax({ url: urlToCheck, dataType: 'script' });
	} else {
    if (debug) console.log("[exportStatusWorker] checkExportStatus: " + checkExportStatus)
	}
};

// Refresh the export status of the requested report
function refreshExportStatus(exportId, exportStatus, button_dom_id, status_dom_id) {
  if (debug) console.log("[refreshExportStatus] exportId: " + exportId + ", exportStatus: " + exportStatus)
  var button_elem = $('#' + button_dom_id);
  var status_elem = $('#' + status_dom_id);

  button_elem.removeClass("generating").removeClass("error")
  status_elem.removeClass("generating").removeClass("error")
  exportReportId = exportId;
  checkExportStatus = false;
  
  switch (exportStatus) {
  case 'generating':
    checkExportStatus = true;
    button_elem.addClass("generating").html("Generating...")
    status_elem.addClass("generating").html("Your file is being generated, which may take quite awhile. You can leave this page and come back later to download the file.")
    break;
    
  case 'generated':
    button_elem.html("Download is Ready")
    status_elem.html("Ready to download")
    break;
    
  case 'error':
    button_elem.addClass("error").html("Download in Excel")
    status_elem.addClass("error").html("There was an error generating the file. Please try again.")
    break;
    
  case 'expired':
    button_elem.html("Download in Excel")
    status_elem.html("Export expired.")
    break;
    
  case 'initializing':
    checkExportStatus = true;
    button_elem.html("Generating...")
    status_elem.children("a").html("Restart")
    break;
    
  default:
    status_elem.html(exportStatus) 
  }
}