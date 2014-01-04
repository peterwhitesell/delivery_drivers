assignerApp = angular.module 'AssignerApp', []

assignerApp.controller 'AssignerForm', ($scope, $http) ->
	$scope.form_methods = [
		method: 'assignDelivery'
		name: 'Assign Delivery'
	  ,
	    method: 'unassignDelivery'
	    name: 'Unassign Delivery'
	  ,
	    method: 'editDelivery'
	    name: 'Edit Delivery'
	]
	$scope.paymentTypes = [
		'cash',
		'card'
	]
	$scope.form =
		method: $scope.form_methods[0]
		storeID: 'MyStoreID'
		employeeID: 4
		checkNumber: 5
		minsOld: 0
		phoneNumber: '5126988916'
		customerName: 'Bob'
		address1: '1 Main St'
		address2: 'Suite 100'
		subDivision: ''
		city: ''
		deliveryInstructions: ''
		comments: ''
		price: 10.50
		paymentType: $scope.paymentTypes[0]

	$scope.getTimePlaced = ->
		new Date().getTime() - 60*1000*$scope.form.minsOld
	$scope.submit = ->
		$http.post 'http://localhost:3000/from-POS',
			messageType: $scope.form.method.method
			storeID: $scope.form.storeID
			employeeID: $scope.form.employeeID
			delivery:
				timePlaced: $scope.getTimePlaced()
				checkNumber: $scope.form.checkNumber
				phoneNumber: $scope.form.phoneNumber
				customerName: $scope.form.customerName
				address1: $scope.form.address1
				address2: $scope.form.address2
				subDivision: $scope.form.subDivision
				city: $scope.form.city
				deliveryInstructions: $scope.form.deliveryInstructions
				comments: $scope.form.comments
				price: $scope.form.price
				paymentType: $scope.form.paymentType