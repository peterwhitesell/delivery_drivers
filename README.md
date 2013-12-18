delivery_drivers
================

A service to extend the delivery driver dispatch functionality of point of sales systems.
app.js is a Node.js app that does two things. It listens for deliver assignments and unassignments from POS systems via HTTP POST requests, and serves a browser app for delivery drivers, designed to for mobile devices. 

The browser app shows drivers what deliveries are assigned to them, with one touch features for calling customers, mapping their addresses and calling the store. 

Having all of this information at the delivery drivers' fingertips saves time and effort by organizing all the information they need to make several deliveries in one trip, while avoiding the repetitive and redundant task of entering addresses and phone numbers into their phones that have already been entered when the orders were taken. 

Because of the ubiquity of the HTTP protocol, integration with existing point of sales systems is straightforward and easy. When a delivery is assigned or unassigned, the system need only make the appropriate HTTP POST request, and the delivery driver app server takes care of the rest. 

HTTP POST requests from POS systems should look like this:

<pre>
POST delivery_drivers_app_url/from-POS HTTP/1.1
Content-Type: application/json

{
  "messageType":"assignDelivery",
  "storeID":"JimmyJohns416",
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
or
<pre>
POST delivery_drivers_app_url/from-POS HTTP/1.1
Content-Type: application/json

{
  "messageType":"unassignDelivery",
  "storeID":"JimmyJohns416",
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
or
<pre>
POST delivery_drivers_app_url/from-POS HTTP/1.1
Content-Type: application/json

{
  "messageType":"editDelivery",
  "storeID":"JimmyJohns416",
  "employeeID":"4",
  "delivery":
  {
    "timePlaced":"1369252307781",
    "checkNumber":"551",
    "phoneNumber":"5126988915",
    "customerName":"James",
    "address1":"607 e 38th",
    "address2":"duplex left side",
    "subDivision":"", "city":"Austin",
    "deliveryInstructions":"",
    "comments":"call don't knock",
    "price":"$10.80",
    "paymentType":"card"
  }
}
</pre>
