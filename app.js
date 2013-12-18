// Generated by CoffeeScript 1.6.3
(function() {
  var Delivery, Employee, Store, app, data, everyone, express, handlePOSMessage, http, nowjs, receive, server;

  express = require('express');

  nowjs = require('now');

  http = require('http');

  app = express();

  app.configure(function() {
    app.use(express.bodyParser());
    app.use(express["static"](__dirname + '/static'));
    return app.use(express.bodyParser());
  });

  server = http.createServer(app);

  server.listen(3001);

  everyone = nowjs.initialize(server);

  app.post('/from-POS', function(req, res) {
    var message;
    message = req.body;
    handlePOSMessage(message);
    console.log(message.method);
    return res.end('success\n');
  });

  everyone.now.serverLog = function(msg) {
    console.log(msg);
    return this.now.receiveMessage(msg);
  };

  everyone.now.serverEval = function(code) {
    return eval(code);
  };

  Store = (function() {
    function Store(storeID) {
      this.storeID = storeID;
      this.employees = {};
    }

    Store.prototype.addEmployee = function(employeeID) {
      return this.employees[employeeID] = new Employee(employeeID, this.storeID);
    };

    return Store;

  })();

  Employee = (function() {
    function Employee(employeeID, storeID) {
      this.employeeID = employeeID;
      this.storeID = storeID;
      this.deliveries = [];
      this.clients = nowjs.getGroup("" + this.storeID + employeeID);
      this.dispatched = false;
    }

    Employee.prototype._indexDelivery = function(checkNumber) {
      var d, index, res, _i, _len, _ref;
      res = -1;
      index = 0;
      _ref = this.deliveries;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        d = _ref[_i];
        if (d.checkNumber === checkNumber) {
          res = index;
        }
        index += 1;
      }
      return res;
    };

    Employee.prototype.addClient = function(client) {
      return this.clients.addUser(client.user.clientId);
    };

    Employee.prototype.addDelivery = function(delivery) {
      this.deliveries.push(delivery);
      return this.dispatched = new Date().getTime();
    };

    Employee.prototype.editDelivery = function(delivery) {
      var i;
      i = this._indexDelivery(delivery.checkNumber);
      return this.deliveries[i] = delivery;
    };

    Employee.prototype.removeDelivery = function(delivery) {
      var i;
      i = this._indexDelivery(delivery.checkNumber);
      this.deliveries.splice(i, 1);
      if (this.deliveries.length === 0) {
        return this.dispatched = false;
      }
    };

    return Employee;

  })();

  Delivery = (function() {
    function Delivery(jsonDelivery) {
      this.checkNumber = jsonDelivery.checkNumber;
      this.phoneNumber = jsonDelivery.phoneNumber;
      this.customerName = jsonDelivery.customerName;
      this.address1 = jsonDelivery.address1;
      this.address2 = jsonDelivery.address2;
      this.subDivision = jsonDelivery.subDivision;
      this.city = jsonDelivery.city;
      this.deliveryInstructions = jsonDelivery.deliveryInstructions;
      this.comments = jsonDelivery.comments;
      this.price = jsonDelivery.price;
      this.paymentType = jsonDelivery.paymentType;
      this.timePlaced = jsonDelivery.timePlaced;
      this.timeAssigned = new Date().getTime();
    }

    return Delivery;

  })();

  data = {
    stores: {},
    ensureStoreExists: function(storeID) {
      if (this.stores[storeID] == null) {
        return this.stores[storeID] = new Store(storeID);
      }
    },
    ensureEmployeeExists: function(storeID, employeeID) {
      var store;
      this.ensureStoreExists(storeID);
      store = this.stores[storeID];
      if (store.employees[employeeID] == null) {
        return store.addEmployee(employeeID);
      }
    }
  };

  handlePOSMessage = function(jsonMessage) {
    console.log("handlePOSMessage\n  messageType: " + jsonMessage.messageType + "\n  storeID: " + jsonMessage.storeID + "\n  employeeID: " + jsonMessage.employeeID + "\n  delivery: ");
    console.log(jsonMessage.delivery);
    return receive[jsonMessage.messageType](jsonMessage.storeID, jsonMessage.employeeID, new Delivery(jsonMessage.delivery));
  };

  receive = {
    assignDelivery: function(storeID, employeeID, delivery) {
      var employee;
      console.log("receive.assignDelivery");
      console.log("  storeID: " + storeID + "\n  employeeID: " + employeeID + "\n  delivery: ");
      console.log(delivery);
      data.ensureEmployeeExists(storeID, employeeID);
      employee = data.stores[storeID].employees[employeeID];
      employee.addDelivery(delivery);
      return employee.clients.now.clientAssignDelivery(delivery, employee.dispatched);
    },
    unassignDelivery: function(storeID, employeeID, delivery) {
      var employee;
      console.log("receive.unassignDelivery");
      console.log("  storeID: " + storeID + "\n  employeeID: " + employeeID + "\n  delivery: ");
      console.log(delivery);
      data.ensureEmployeeExists(storeID, employeeID);
      employee = data.stores[storeID].employees[employeeID];
      employee.removeDelivery(delivery);
      return employee.clients.now.clientUnassignDelivery(delivery, employee.dispatched);
    },
    editDelivery: function(storeID, employeeID, editedDelivery) {
      var employee;
      console.log("receive.editDelivery");
      console.log("  storeID: " + storeID + "\n  employeeID: " + employeeID + "\n  delivery: ");
      console.log(editedDelivery);
      data.ensureEmployeeExists(storeID, employeeID);
      employee = data.stores[storeID].employees[employeeID];
      employee.editDelivery(editedDelivery);
      return employee.clients.now.clientEditDelivery(editedDelivery);
    }
  };

  everyone.now.login = function(storeID, employeeID) {
    var d, employee, _i, _len, _ref, _results;
    console.log("" + storeID + "'s employee, " + employeeID + " just logged in");
    data.ensureEmployeeExists(storeID, employeeID);
    employee = data.stores[storeID].employees[employeeID];
    employee.addClient(this);
    _ref = employee.deliveries;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      d = _ref[_i];
      _results.push(this.now.clientAssignDelivery(d, employee.dispatched));
    }
    return _results;
  };

}).call(this);