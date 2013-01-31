# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

to_percent = (f) ->
  (f * 100).toFixed(2) + "%"

monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

((o) ->
  Number.getOrdinalFor = (intNum, includeNumber) ->
    ((if includeNumber then intNum else "")) + (o[((intNum = Math.abs(intNum % 100)) - 20) % 10] or o[intNum] or "th")
) ["", "st", "nd", "rd"]

$ ->
  $("form").submit ->
    $("#result_box").hide()
    username = $("#username").val()
    $.ajax("/user/" + username + ".json").done((response) ->
      $("#error").text ""
      $(".username").text username
      time = new Date(response["updated_at"])
      overall = response["percentile"]
      month = response["month_percentile"]
      karma = response["karma"]
      reg = new Date(response["date_registered"])
      month_name = monthNames[reg.getMonth()]
      full_year = reg.getFullYear()
      $(".reg_month").text month_name + " " + full_year
      $(".reg_month").attr "href", "/month/" + month_name.toLowerCase() + "-" + full_year
      bc = overall["below_karma"]
      total = overall["population"]
      $("#overall .percentile").text to_percent(overall["percentile"])
      $("#overall .total").text total
      $("#overall .below_karma").text bc
      $("#overall .rank").text Number.getOrdinalFor(Number(total) - Number(bc), true)
      bc = month["below_karma"]
      total = month["population"]
      $("#reg_month .percentile").text to_percent(month["percentile"])
      $("#reg_month .total").text total
      $("#reg_month .below_karma").text bc
      $("#reg_month .rank").text Number.getOrdinalFor(Number(total) - Number(bc), true)
      $("#time").text time
      $(".karma").text karma
      $("#result_box").show()
    ).error (response) ->
      $("#error").text "Invalid Username"

    false
  false
