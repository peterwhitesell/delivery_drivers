socket = io.connect 'http://192.168.0.2'

$(document).ready ->
  $("#login-button").click ->
    socket.emit 'login',
      "storeID": $("#storeID").val(),
      "employeeID": $("#employeeID").val()
    $("#login").remove()
    $("#content").show()


  $("#storeID").keypress (e) ->
    if e.which and e.which == 13
      $("#employeeID").focus()

  $("#employeeID").keypress (e) ->
    if e.which and e.which == 13
      $("#login-button").click()
      return false

  $("#storeID").focus()

  $("#deliverytable").on "click", "tr", ->
    $(@).find(".expanded").toggle()
  $("#deliverytable").on "click", "a", (e) ->
    e.stopPropagation()

  updateTimes()

sortDeliveries = ->
  ds = $("#deliverytable tbody").children()
  sort_by_checkNumber = (d1, d2) ->
    num1 = parseInt $(d1).children().filter(".checkNumber").html()
    num2 = parseInt $(d2).children().filter(".checkNumber").html()
    return -1 if num1 < num2
    return 1 if num1 > num2
    return 0
  ds.sort sort_by_checkNumber
  for d in ds
    d.parentNode.appendChild d

updateTimes = ->
  ds = $("#deliverytable tbody").children()
  for d in ds
    updateTime d
  if $("#dispatchedtime").attr("time") == "false"
    updateDispatchTime false
  else
    updateDispatchTime $("#dispatchedtime").attr("time")
  setTimeout ->
    updateTimes()
  , 1000

updateTime = (deliveryElement) ->
  time_placed = $(deliveryElement).attr("timeplaced")
  current_time = new Date().getTime()
  minutes_since_placed = Math.round (current_time - time_placed)/60000
  $(deliveryElement).children().filter(".time").html(minutes_since_placed)

updateTableStripes = ->
  bgs = ["lightgray", "white"]
  deliveries = $("#deliveries").children()
  for i in [0...deliveries.length]
    $(deliveries[i]).css "background-color", bgs[i%2]

updateDispatchTime = (dispatched) ->
  if dispatched
    $("#notdispatched").hide()
    $("#dispatched").show()
    dispatched_time = Math.round (new Date().getTime() - dispatched)/60000
    $("#dispatchedtime").html dispatched_time
  else
    $("#notdispatched").show()
    $("#dispatched").hide()
  $("#dispatchedtime").attr "time", dispatched

assignDelivery = (delivery, dispatched) ->
  d = $("<tr id='d#{delivery.checkNumber}' class='delivery' timeplaced='#{delivery.timePlaced}'></tr>")
  $("<td class='checkNumber'>#{delivery.checkNumber}</td>").appendTo d
  urlAddress = delivery.address1.split(" ").join("+")
  address = "<td class='address'><a class='btn btn-success' href='http://maps.google.com/?q=#{urlAddress}'>#{delivery.address1}</a><div id='de#{delivery.checkNumber}' class='expanded'>"
  for info in ["#{delivery.address2}", "#{delivery.customerName}", "<a class='btn btn-info' href='tel:#{delivery.phoneNumber}'>#{delivery.phoneNumber}</a>", "#{delivery.comments}", "#{delivery.deliveryInstructions}"]
    unless info == ""
      address = address + info + "</br>"
  address = address + "#{delivery.price} #{delivery.paymentType}" + "</div></td>"
  $(address).appendTo d
  time = $("<td class='time'></td>")
  time.appendTo d
  updateTime d
  d.appendTo $("#deliverytable")
  sortDeliveries()
  updateTableStripes()
  updateDispatchTime dispatched


unassignDelivery = (delivery, dispatched) ->
  $("#d#{delivery.checkNumber}").remove()
  updateTableStripes()
  updateDispatchTime dispatched

editDelivery = (delivery) ->
  unassignDelivery delivery
  assignDelivery delivery

socket.on 'clientAssignDelivery', (data) ->
  assignDelivery data.delivery, data.dispatched

socket.on 'clientUnassignDelivery', (data) ->
  unassignDelivery data.delivery, data.dispatched

socket.on 'clientEditDelivery', (data) ->
  editDelivery data.delivery

app = angular.module 'DeliveryApp', []