deliveryApp = angular.module 'DeliveryApp', []

deliveryApp.directive 'expander', ->
  restrict: 'A',
  link: (scope, element) ->
    element.bind 'click', -> element.find('[expand]').toggle()

deliveryApp.directive 'expand', ->
  restrict: 'A',
  link: (scope, element) ->
    element.hide()

deliveryApp.directive 'delivery', ->
  restrict: 'A',
  templateUrl: 'delivery.html'

deliveryApp.directive 'extraInfo', ->
  restrict: 'E',
  templateUrl: 'extraInfo.html'

deliveryApp.controller 'DeliveryTable', ($scope, $timeout) ->
  $scope.employeeID = 4
  $scope.storeID = 'MyStoreID'
  $scope.dispatched = new Date().getTime()

  $scope.deliveries = {}

  $scope.getDeliveries = ->
    deliveries = []
    for id,delivery of $scope.deliveries
      deliveries.push delivery
    return deliveries
  
  $scope.noDeliveries = ->
    $.isEmptyObject $scope.deliveries

  $scope.getURLAddress = (address) ->
    return "http://maps.google.com/?q=" + encodeURIComponent address

  updateTime = ->
    $scope.currentTime = new Date().getTime()
    $timeout updateTime, 1000
  updateTime()

  $scope.getTime = (timePlaced) ->
    return Math.round ($scope.currentTime - timePlaced) / 60000

  $scope.getDispatched = ->
    return $scope.getTime $scope.dispatched

  socket = io.connect 'http://localhost'

  $scope.login = ->
    $scope.deliveries = {}
    socket.emit 'login',
      "storeID": $scope.storeID,
      "employeeID": $scope.employeeID
  
  socket.on 'clientAssignDelivery', (data) ->
    $scope.deliveries[data.delivery.checkNumber] = data.delivery
    $scope.dispatched = data.dispatched

  socket.on 'clientUnassignDelivery', (data) ->
    delete $scope.deliveries[data.delivery.checkNumber]
    $scope.dispatched = data.dispatched

  socket.on 'clientEditDelivery', (data) ->
    $scope.deliveries[data.delivery.checkNumber] = data.delivery
    $scope.dispatched = data.dispatched

  $scope.login()

