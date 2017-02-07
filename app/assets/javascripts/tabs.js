(function() {
  this.App || (this.App = {});

  App.tabs = (function(_selector) {
    var selector = _selector;
    
    var init = {
      
      // Run just once (global handlers)
      globals: function() {
        init.bind.keyboardControls()
      },
      
      // Run every time the page is loaded.
      always: function() {
        init.bind.tabEvents()
        navigation.url.load();
      },
      
      bind: {
        
        // Binds the event handlers for the left and right keys to switch betwen tabs.
        keyboardControls: function() {
          $( document ).keydown(function (event) {
            if($(document.activeElement).is('textarea,input,select')) { return; }
            switch (event.which) {
            case $.ui.keyCode.LEFT:
              event.preventDefault();
              navigation.prev();
              break;
            case $.ui.keyCode.RIGHT:
              event.preventDefault();
              navigation.next();
              break;
            default: return;
            }
          })
        },
        
        // Bind when the tab is shown so that we can fetch delayed content, etc.
        tabEvents: function() {
          $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
            var elem = $(e.target)
            navigation.url.update()
            $(elem.attr('href')).find("[data-delayed-content-path]").each(function() {
              content.fetch($( this ))
            })
          })
        }
        
      }
    }
    
    var content = {
      
      // Fetch delayed content for the specified element, based on the path in the
      // +data-delayed-content-path+ attribute.
      fetch: function(element) {
        var path = element.data('delayed-content-path')
        var url = window.location.pathname + "/" + path
        if (element.data('fetched-at') !== undefined) return false;
        console.log("Fetching tab content from " + url)
        $.ajax({
          url: url,
          context: element,
          headers: { "X-DreamSIS-Render-Intent": "no-layout" }
        })
          .done(function( html ) {
            $(this)
              .attr('data-fetched-at', (new Date).toISOString())
              .attr('role', 'content')
              .html( html )
          })
          .fail(function() {
            $("<div>")
              .addClass("alert alert-danger")
              .attr('role', 'alert')
              .html('Sorry, the content could not be loaded.')
              .prepend("<i class='fa fa-exclamation-triangle' aria-hidden='true'></i> ")
              .replaceAll($(this))
          })
      },
      
      reset: function() {
        $('[data-delayed-content-path]').attr('data-fetched-at', null).attr('role', 'placeholder')
      }
      
    }
    
    var navigation = {
      
      // Gets the index ID of the currently active tab.
      _currentIndex: function() {
        return $(selector).find('.active').index()
      },
      
      // Returns the ID of the currently selected tab
      _currentId: function() {
        return $(selector).find('.active a').attr('href').substr(1)
      },
      
      // Switch to the "next" tab
      next: function() {
        nextIndex = navigation._currentIndex() + 1
        return $(selector).find('li:eq(' + nextIndex + ') a').tab('show')
      },
      
      // Switch to the "previous" tab
      prev: function() {
        prevIndex = navigation._currentIndex() - 1
        return $(selector).find('li:eq(' + prevIndex + ') a').tab('show')
      },
      
      // Switch to the tab with the specified ID
      goTo: function(tab_id) {
        $(selector).find('a[href="#' + tab_id + '"]').tab('show')
      },
      
      // Functions pertaining to the URL hash.
      url: {
        
        // Update the URL with the currently selected tab
        update: function() {
          var new_hash = "!/section/" + navigation._currentId()
          window.location.hash = new_hash
        },
        
        // Switches to the tab specified in the URL hash
        load: function() {
          var regex = /#!\/section\/(\w+)\/?(\d+)?&?(\w+=\w+)*/
          var tabHashMatch = decodeURIComponent(window.location.hash).match(regex)
          if(tabHashMatch && tabHashMatch[1]) {
          	navigation.goTo(tabHashMatch[1]) //, tabHashMatch[2], tabHashMatch[3]);
          }
        }
        
      }
      
    }
    
    return {
      initialize: function(_selector) {
        selector = _selector;
        init.always();
      },
      init: init,
      content: content,
      navigation: navigation
    }
  
  })();

}).call(this);

$(function() {
  App.tabs.init.globals()
})

$(document).on('turbolinks:load', function(event) {
  App.tabs.initialize(".nav-tabs")
})
