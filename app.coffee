express = require 'express'
http = require 'http'
socketio = require 'socket.io'

#express app initialization
app = express()
app.configure ->
  app.use express.bodyParser()
  app.use express.static(__dirname + '/static')
  
server = http.createServer(app)

io = socketio.listen server
io.set('log level', 1);

server.listen 3000

#receives http post requests made to .../from-POS. 
app.post '/from-POS', (req, res) ->
  message = req.body
  handlePOSMessage message
  res.end 'success\n'

#a class to for stores
class Store
  constructor: (@storeID) ->
    @employees = {}
  addEmployee: (employeeID) ->
    @employees[employeeID] = new Employee(employeeID, @storeID)

#a class for employees
class Employee
  constructor: (@employeeID, @storeID) ->
    @deliveries = []
    @dispatched = false
  _indexDelivery: (checkNumber) -> #test this
    res = -1
    index = 0
    for d in @deliveries
      if d.checkNumber == checkNumber
        res = index
      index += 1
    return res
  addDelivery: (delivery) ->
    @deliveries.push delivery
    @dispatched = new Date().getTime()
    
  editDelivery: (delivery) ->
    i = @_indexDelivery delivery.checkNumber
    @deliveries[i] = delivery
  removeDelivery: (delivery) ->
    i = @_indexDelivery delivery.checkNumber
    @deliveries.splice i, 1
    if @deliveries.length == 0
      @dispatched = false

#a class for deliveries
class Delivery
  constructor: (jsonDelivery) ->
    @checkNumber = jsonDelivery.checkNumber
    @phoneNumber = jsonDelivery.phoneNumber
    @customerName = jsonDelivery.customerName
    @address1 = jsonDelivery.address1
    @address2 = jsonDelivery.address2
    @subDivision = jsonDelivery.subDivision
    @city = jsonDelivery.city
    @deliveryInstructions = jsonDelivery.deliveryInstructions
    @comments = jsonDelivery.comments
    @price = jsonDelivery.price
    @paymentType = jsonDelivery.paymentType
    @timePlaced = jsonDelivery.timePlaced
    @timeAssigned = new Date().getTime()

#a namespace for functions that handle the local storage of stores, employees and deliveries
data =
  #an object that stores a map from each store ID to a Store object
  stores: {}
  #called upon receiving a message from POS to ensure there is a record for the relevant store
  ensureStoreExists: (storeID) ->
    unless @stores[storeID]?
      @stores[storeID] = new Store(storeID)
  #called upon receiving a message from POS to ensure there is a record for the relevant employee
  ensureEmployeeExists: (storeID, employeeID) ->
    @ensureStoreExists storeID
    store = @stores[storeID]
    unless store.employees[employeeID]?
      store.addEmployee employeeID
  

#a function that receives messages from POS and calls the appropriate function of receive. jsonMessage should be of the form {messageType:messageType, storeID:storeID, employeeID:employeeID, delivery:delivery}
handlePOSMessage = (jsonMessage) ->
  console.log "handlePOSMessage\n  messageType: #{jsonMessage.messageType}\n  storeID: #{jsonMessage.storeID}\n  employeeID: #{jsonMessage.employeeID}\n  delivery: "
  console.log jsonMessage.delivery
  receive[jsonMessage.messageType] jsonMessage.storeID, jsonMessage.employeeID, new Delivery(jsonMessage.delivery)

#a set of functions to be called in response to messages from POS
receive = 
  #a function that receives a delivery assignment from POS, stores the delivery locally and passes the assignment on to the appropriate clients
  #delivery should be of the form {timePlaced:timePlaced, checkNumber:checkNumber, phoneNumber:phoneNumber, customerName:customerName, address1:address1, address2:address2, subDivision:subDivision, city:city, deliveryInstructions:deliveryInstructions, comments:comments, price:price, paymentType:paymentType}
  assignDelivery: (storeID, employeeID, delivery) -> 
    console.log "receive.assignDelivery"
    console.log "  storeID: #{storeID}\n  employeeID: #{employeeID}\n  delivery: "
    console.log delivery
    data.ensureEmployeeExists storeID, employeeID
    employee = data.stores[storeID].employees[employeeID]
    employee.addDelivery delivery
    io.sockets.in(storeID + employeeID).emit 'clientAssignDelivery',
      "delivery": delivery,
      "dispatched": employee.dispatched

  #a function that recieves a delivery unassignment from POS, removes the delivery from local storage and passes the unassignment on to the appropriate clients
  unassignDelivery: (storeID, employeeID, delivery) ->
    console.log "receive.unassignDelivery"
    console.log "  storeID: #{storeID}\n  employeeID: #{employeeID}\n  delivery: "
    console.log delivery
    data.ensureEmployeeExists storeID, employeeID
    employee = data.stores[storeID].employees[employeeID]
    employee.removeDelivery delivery
    io.sockets.in(storeID + employeeID).emit 'clientUnassignDelivery',
      "delivery": delivery,
      "dispatched": employee.dispatched

  #a function that receives a delivery edit from POS, edits the corresponding delivery in local storage and passes the edit along to the appropriate clients
  editDelivery: (storeID, employeeID, editedDelivery) ->
    console.log "receive.editDelivery"
    console.log "  storeID: #{storeID}\n  employeeID: #{employeeID}\n  delivery: "
    console.log editedDelivery
    data.ensureEmployeeExists storeID, employeeID
    employee = data.stores[storeID].employees[employeeID]
    employee.editDelivery editedDelivery
    io.sockets.in(storeID + employeeID).emit 'clientEditDelivery',
      "delivery": editedDelivery

#when a client logs in as an employee, send delivery assignments to the client for all deliveries that are currently stored locally for that employee. store the client's socket
io.sockets.on 'connection', (socket) ->
  socket.on 'login', (args) ->

    socket.leave socket.room
    socket.room = args.storeID + args.employeeID
    socket.join socket.room

    console.log "#{args.storeID}'s employee, #{args.employeeID} just logged in"
    data.ensureEmployeeExists args.storeID, args.employeeID
    employee = data.stores[args.storeID].employees[args.employeeID]

    for d in employee.deliveries
      socket.emit 'clientAssignDelivery',
        "delivery": d,
        "dispatched": employee.dispatched
