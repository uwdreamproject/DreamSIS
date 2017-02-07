$ ->
  $("a#menu_expander_link").click ->
    $('body').toggleClass('menu_view')
  
  $("a#sidebar_expander_link").click ->
    $('body').toggleClass('sidebar_view')
  
