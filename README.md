delivery_drivers
================
delivery_drivers includes a simple mobile browser app for delivery drivers, showing them what orders are assigned to them and providing one-touch options for calling customers or mapping their addresses. 

Having all of this information at the delivery drivers' fingertips saves time and effort by organizing all the information they need to make several deliveries in one trip, while avoiding the repetitive and redundant task of entering addresses and phone numbers into their phones that have already been entered when the orders were taken. 

delivery_drivers is designed to be easily integrated with existing point of sales systems. The [node.js](http://nodejs.org/) server listens for HTTP POST requests from point of sales systems, which can be used to assign or unassign deliveries or to edit deliveries that are already assigned. An instance of delivery_drivers can handle multiple stores with multiple employees.

delivery_drivers' node.js app saves what deliveries are assigned to which employees in memory and uses WebSockets via [socket.io](http://socket.io/) to push changes to connected clients. When a client connects, he/she receives all deliveries currently assigned to him/her. 

On the user end, delivery_drivers serves a clean, simple, mobile-friendly interface built with [angular.js](http://angularjs.org/) and [Twitter Bootstrap](http://getbootstrap.com/) for the browser. The user sees an easy way to log in, how long he/she has been away from the store and a list of deliveries that are assigned to him/her. Deliheveries in the list show the most important information up front (the check number, address and delivery age) and expand with a touch to show details such as delivery instructions, phone number, price, etc. 

I've also included a simple web form for assigning/unassigning/editing deliveries for demonstration purposes. It uses angular.js's $http service to pretend to be a POS system, sending HTTP POST requests to the server. If you prefer, you can easily test with UNIX ``curl`` or any other HTTP wrapper. 

Usage and Integration
---------------------
To install:
<pre>
git clone https://github.com/peterwhitesell/delivery_drivers.git
cd delivery_drivers
./make
</pre>

To start the server:
<pre>
node app.js
</pre>

To communicate from a POS system:
<pre>
POST delivery_drivers_app_url/from-POS HTTP/1.1
Content-Type: application/json

{
  "messageType":"assignDelivery",
  "storeID":"MyStoreID",
  "employeeID":"4",
  "delivery":
  {
    "timePlaced":"1369252307781",
    "checkNumber":"551",
    "phoneNumber":"5126988915",
    "customerName":"James",
    "address1":"607 e 38th",
    "address2":"duplex right side",
    "subDivision":"", "city":"",
    "deliveryInstructions":"",
    "comments":"knock loudly",
    "price":"$10.80",
    "paymentType":"cash"
  }
}
</pre>
``"messageType"`` can be ``"assignDelivery"``, ``"unassignDelivery"`` or ``"editDelivery"``.

To connect as a client:
Point your browser to [http://localhost:3000]([http://localhost:3000)

To use the web form to assign/unassign/edit deliveries:
Point your browser to [http://localhost:3000/assigner.html](http://localhost:3000/assigner.html)

Demo
----
I've hosted a demo on an AWS EC2 micro instance [here](ec2-54-209-154-196.compute-1.amazonaws.com:8080)
You can use the assigner [here](ec2-54-209-154-196.compute-1.amazonaws.com:8080/assigner.html)

TODO
----
* Add authentication schemes for employees signing in and for requests from POS systems
