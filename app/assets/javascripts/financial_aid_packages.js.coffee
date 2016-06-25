# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("select#financial_aid_source_source_type_id").change ->
    if $("#financial_aid_source_source_type_id option").filter(":selected").parent("optgroup").attr("label") == "Grants & Scholarships"
      $("#financial_aid_source_scholarship_application_id").show()
    else
      $("#financial_aid_source_scholarship_application_id").hide()
    
    $("#financial_aid_source_amount").select()

  $("#financial_aid_source_scholarship_application_id").change ->
    $("#financial_aid_source_amount").select()

  $('#new_financial_aid_source').on 'ajax:success', (e, data, status, xhr) =>
    updateCostBreakdown(data.breakdown)
    $("#financial_aid_sources_table > tbody").append(data.content)
    $("a.destroy").on "ajax:success", (e, data, status, xhr) -> handleDestroy e, data, status, xhr
    resetForm()
  
  $("a.destroy").on "ajax:success", (e, data, status, xhr) -> handleDestroy e, data, status, xhr
  
  handleDestroy = (e, data, status, xhr) ->
    $(e.currentTarget).parents("tr").remove()
    callback = (data) -> updateCostBreakdown data.breakdown
    $.get window.location.href, {}, callback, 'json'
  
  resetForm = (form) ->
    $('#new_financial_aid_source')[0].reset()
    $("#financial_aid_source_scholarship_application_id").hide()
    $("select#financial_aid_source_source_type_id").focus()
  
  # Update the visual cost breakdown on the screen with a new hash of costs.
  updateCostBreakdown = (new_breakdown) ->
    console.log(new_breakdown)
    for category, breakdown of new_breakdown
      $(".cost-component.#{category}").toggleClass("hidden", (breakdown["amount_raw"] <= 0))
      $(".cost-component.#{category} .amount").text("#{breakdown["amount_formatted"]}")
      $(".cost-label.#{category}").toggleClass("hidden", (breakdown["amount_raw"] <= 0))
      $(".cost-label.#{category}")
        .next("dd")
        .toggleClass("hidden", (breakdown["amount_raw"] <= 0))
        .find(".amount").text("#{breakdown["amount_formatted"]}")
      $(".cost-component.#{category}").css("width", "#{breakdown["percentage"]}%")
      setTimeout ->
        $(".cost-component").each ->
          $(this).toggle().toggle()
      , 350
      
