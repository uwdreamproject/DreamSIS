(function() {
  this.App || (this.App = {});

  App.exportable = (function() {

    var status_url = "/participants/export_status.json";
    
    var init = {
      
      // Setup the event listeners for reports.
      bindEvents: function() {
        $(document).on('click', 'form.export_actions button[type=submit]', function(event) {
          event.preventDefault()
          status.get()
        })
        
        $(document).on('click', '#modal-export-actions .subscriptions .remove', function(event) {
          event.preventDefault()
          var report_id = $(this).parents('.list-group-item').data('report-id')
          display.remove(report_id)
        })
        
        $(document).on('click', '#modal-export-actions .subscriptions .regenerate', function(event) {
          var report_id = $(this).parents('.list-group-item').data('report-id')
          display.reset(report_id)
        })
      }
      
    };
    
    var status = {
      
      // Gets the current status of the report from the server.
      get: function() {
        display.indicator('show');
        $.getJSON(status_url, {
          filter_selections: App.filterable.filters.get(),
          report: $("form.export_actions select").val(),
          generate: 'if-needed'
         })
          .done(function( data ) {
            // console.log(data)
            status.subscribe(data.id);
            display.report(data.id);
            display.update.all(data);
          });
      },
      
      // Returns the html to display for the current report's status,
      // based on the JSON returned from server.
      html: function(data) {
        switch (data.status) {
        case null:
          return "Not yet generated.";
        case 'generating':
          return "Your file is being generated, which may take quite awhile. You can leave this page and come back later to download the file. ";
        case 'generated':
          return $("<span>")
            .text("Generated ")
            .append($("<time>")
            .addClass("livestamp")
            .text("at" + data.generated_at)
            .attr("datetime", data.generated_at)
            .livestamp());
        case 'error':
          return $("<p class='text-danger'>There was an error generating the file. Please try again.</p>");
        case 'expired':
          return $("<p class='text-warning'>Export expired.</p>");
        case 'initializing':
          return "Generating...";
        default:
          return data.status;
        }
      },
      
      // Subscribe to updates about this report
      subscribe: function(report_id) {
        return App.cable.subscriptions.create({ channel: 'ReportsChannel', report_id: report_id }, {
          received: function(data) {
            display.update.all(data)
          },
          connected: function() {
            console.log("Subscribed to ReportsChannel " + report_id)
          },
          disconnected: function() {
            console.log("Disconnected from subscription")
          },
          rejected: function() {
            console.error("Subscription rejected by server")
          }
        });
      }
    };
    
    var display = {
      
      // Show or hide the progress indicator in the modal.
      indicator: function(command) {
        $(".indicator.export_actions").toggleClass("hidden", command == 'hide')
      },
      
      // Add the report (with specified ID) to the list of reports that we care
      // about in the export modal, by cloning the hidden template elements and
      // appending them to the visible list.
      report: function(report_id) {
        var elem = $("[data-report-id=" + report_id + "]")
        if (elem.length > 0) return elem;
        return $('#modal-export-actions .template')
          .clone()
          .removeClass('hidden template')
          .attr('data-report-id', report_id)
          .prependTo('#modal-export-actions .list-group')
      },
      
      // Remove the specified report from the modal list - we don't want to see it anymore.
      remove: function(report_id) {
        $("[data-report-id=" + report_id + "]").remove()
      },
      
      // Reset the progress bar to zero for the specified report. Includes a CSS class
      // to temporarily disable the Bootstrap animation while resetting it.
      reset: function(report_id) {
        var elem = display.report(report_id);
        elem.find('.progress-bar')
          .addClass('notransition')
          .css('width', 0)
          .attr('aria-valuenow', 0)
          .text("0%")
        elem.find('.btn-group.open').removeClass('open')
      },
      
      update: {
        
        // Given a data payload, update everything on the screen as appropriate.
        all: function(data) {
          display.update.status(data);
          display.update.title(data);
          display.update.progress(data);
          display.update.links(data);
          display.indicator('hide');
        },
        
        // Update the progress bar percentage.
        progress: function(data) {
          var elem = display.report(data.id).find('.progress-bar');
          if (!data.processed) return;
          elem
            .removeClass("active progress-bar-striped notransition")
            .css('width', data.percent + "%")
            .attr('aria-valuenow', data.percent)
            .text(data.percent + "%")
          if (data.percent == "100" && data.status != "generated") {
            elem.addClass("active progress-bar-striped")
          }
        },
        
        // Update the status text.
        status: function(data) {
          display.report(data.id).find('.status').html(status.html(data));
        },
        
        // Update the title that's shown in the list.
        title: function(data) {
          var elem = display.report(data.id).find('.title');
          elem.html(data.type);
          if (data.total) elem.append(" &bull; " + data.total + " records");
        },
        
        // Update the action links to download and regenerate the files.
        links: function(data) {
          var elem = display.report(data.id).find(".actions");
          
          if (data && data.download_url) {
            elem.find("a.download").attr('href', data.download_url).removeClass('disabled')
          } else {
            elem.find("a.download").addClass('disabled')
          }
          
          if (data.regenerate_url) {
            elem.find("a.regenerate").attr('href', data.regenerate_url).removeClass('disabled')
          } else {
            elem.find("a.regenerate").addClass('disabled')
          }
        }
        
      }
      
    };
    
    return {
      initialize: function() {
        init.bindEvents();
      },
      status: status,
      display: display
    }
  })();

}).call(this);

$(function() {
  App.exportable.initialize()
})
