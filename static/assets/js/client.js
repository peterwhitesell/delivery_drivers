// Generated by CoffeeScript 1.6.3
(function() {
  var app, assignDelivery, editDelivery, socket, sortDeliveries, unassignDelivery, updateDispatchTime, updateTableStripes, updateTime, updateTimes;

  socket = io.connect('http://192.168.0.2');

  $(document).ready(function() {
    $("#login-button").click(function() {
      socket.emit('login', {
        "storeID": $("#storeID").val(),
        "employeeID": $("#employeeID").val()
      });
      $("#login").remove();
      return $("#content").show();
    });
    $("#storeID").keypress(function(e) {
      if (e.which && e.which === 13) {
        return $("#employeeID").focus();
      }
    });
    $("#employeeID").keypress(function(e) {
      if (e.which && e.which === 13) {
        $("#login-button").click();
        return false;
      }
    });
    $("#storeID").focus();
    $("#deliverytable").on("click", "tr", function() {
      return $(this).find(".expanded").toggle();
    });
    $("#deliverytable").on("click", "a", function(e) {
      return e.stopPropagation();
    });
    return updateTimes();
  });

  sortDeliveries = function() {
    var d, ds, sort_by_checkNumber, _i, _len, _results;
    ds = $("#deliverytable tbody").children();
    sort_by_checkNumber = function(d1, d2) {
      var num1, num2;
      num1 = parseInt($(d1).children().filter(".checkNumber").html());
      num2 = parseInt($(d2).children().filter(".checkNumber").html());
      if (num1 < num2) {
        return -1;
      }
      if (num1 > num2) {
        return 1;
      }
      return 0;
    };
    ds.sort(sort_by_checkNumber);
    _results = [];
    for (_i = 0, _len = ds.length; _i < _len; _i++) {
      d = ds[_i];
      _results.push(d.parentNode.appendChild(d));
    }
    return _results;
  };

  updateTimes = function() {
    var d, ds, _i, _len;
    ds = $("#deliverytable tbody").children();
    for (_i = 0, _len = ds.length; _i < _len; _i++) {
      d = ds[_i];
      updateTime(d);
    }
    if ($("#dispatchedtime").attr("time") === "false") {
      updateDispatchTime(false);
    } else {
      updateDispatchTime($("#dispatchedtime").attr("time"));
    }
    return setTimeout(function() {
      return updateTimes();
    }, 1000);
  };

  updateTime = function(deliveryElement) {
    var current_time, minutes_since_placed, time_placed;
    time_placed = $(deliveryElement).attr("timeplaced");
    current_time = new Date().getTime();
    minutes_since_placed = Math.round((current_time - time_placed) / 60000);
    return $(deliveryElement).children().filter(".time").html(minutes_since_placed);
  };

  updateTableStripes = function() {
    var bgs, deliveries, i, _i, _ref, _results;
    bgs = ["lightgray", "white"];
    deliveries = $("#deliveries").children();
    _results = [];
    for (i = _i = 0, _ref = deliveries.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      _results.push($(deliveries[i]).css("background-color", bgs[i % 2]));
    }
    return _results;
  };

  updateDispatchTime = function(dispatched) {
    var dispatched_time;
    if (dispatched) {
      $("#notdispatched").hide();
      $("#dispatched").show();
      dispatched_time = Math.round((new Date().getTime() - dispatched) / 60000);
      $("#dispatchedtime").html(dispatched_time);
    } else {
      $("#notdispatched").show();
      $("#dispatched").hide();
    }
    return $("#dispatchedtime").attr("time", dispatched);
  };

  assignDelivery = function(delivery, dispatched) {
    var address, d, info, time, urlAddress, _i, _len, _ref;
    d = $("<tr id='d" + delivery.checkNumber + "' class='delivery' timeplaced='" + delivery.timePlaced + "'></tr>");
    $("<td class='checkNumber'>" + delivery.checkNumber + "</td>").appendTo(d);
    urlAddress = delivery.address1.split(" ").join("+");
    address = "<td class='address'><a class='btn btn-success' href='http://maps.google.com/?q=" + urlAddress + "'>" + delivery.address1 + "</a><div id='de" + delivery.checkNumber + "' class='expanded'>";
    _ref = ["" + delivery.address2, "" + delivery.customerName, "<a class='btn btn-info' href='tel:" + delivery.phoneNumber + "'>" + delivery.phoneNumber + "</a>", "" + delivery.comments, "" + delivery.deliveryInstructions];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      info = _ref[_i];
      if (info !== "") {
        address = address + info + "</br>";
      }
    }
    address = address + ("" + delivery.price + " " + delivery.paymentType) + "</div></td>";
    $(address).appendTo(d);
    time = $("<td class='time'></td>");
    time.appendTo(d);
    updateTime(d);
    d.appendTo($("#deliverytable"));
    sortDeliveries();
    updateTableStripes();
    return updateDispatchTime(dispatched);
  };

  unassignDelivery = function(delivery, dispatched) {
    $("#d" + delivery.checkNumber).remove();
    updateTableStripes();
    return updateDispatchTime(dispatched);
  };

  editDelivery = function(delivery) {
    unassignDelivery(delivery);
    return assignDelivery(delivery);
  };

  socket.on('clientAssignDelivery', function(data) {
    return assignDelivery(data.delivery, data.dispatched);
  });

  socket.on('clientUnassignDelivery', function(data) {
    return unassignDelivery(data.delivery, data.dispatched);
  });

  socket.on('clientEditDelivery', function(data) {
    return editDelivery(data.delivery);
  });

  app = angular.module('DeliveryApp', []);

}).call(this);