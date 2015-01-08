// If a document defines the checkXlsxStatusUrl variable, automatic report checking will turn on.
$(document).ready( function() {
  if (typeof checkXlsxStatusUrl !== 'undefined') {
    var xlsxStatusWorder = function() {
    	if (checkXlsxStatus == true) {
    		$.ajax({ url: checkXlsxStatusUrl, dataType: 'script' });
    	};
    };
    xlsxStatusWorker();
    setInterval('xlsxStatusWorker', 3000);
  }
})

// Refresh the export status of the requested report
function refreshExportStatus(exportId, exportStatus, button_dom_id, status_dom_id) {
  console.log("Checking export status")
  var button_elem = $('#' + button_dom_id);
  var status_elem = $('#' + status_dom_id);

  button_elem.removeClass("generating").removeClass("error")
  status_elem.removeClass("generating").removeClass("error")
  checkXlsxStatus = false;
  
  switch (exportStatus) {
  case 'generating':
    checkXlsxStatus = true;
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
    
  default:
    status_elem.html(exportStatus) 
  }
}