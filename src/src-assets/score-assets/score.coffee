Adventure = angular.module('Adventure', ['ngSanitize'])

## CONTROLLER ##
Adventure.controller 'AdventureScoreCtrl', ['$scope','$sanitize','legacyQsetSrv','$sce', ($scope, $sanitize, legacyQsetSrv, $sce) ->

	materiaCallbacks = {}

	$scope.inventory = []
	$scope.responses = []
	$scope.itemSelection = []

	$scope.setSelectedItem = (item) ->
		$scope.selectedItem = item

	$scope.getItemIndex = (item) ->
		if (item)
			for i, index in $scope.itemSelection
				if i.id is item.id
					return index

	$scope.getQuestion = (qset, id) ->
		for i in qset.items
			console.log(i.id)
			if i.options.id is id
				return i
		return 0

	$scope.createInventoryFromResponses = (qset, responses) ->
		inventory = []

		for r, index in responses
			question = $scope.getQuestion(qset, r.data[1])
			if question
				items = question.options.items || null
				if items
					for responseItem in items
						itemPresent = false
						for item, index in inventory
							if item.id is responseItem.id
								item.count += responseItem.count
								if item.count <= 0
									inventory.splice index, 0
									break
								itemPresent = true
						if !itemPresent
							inventory.push(responseItem)

		return inventory

	$scope.createTable = (qset, scoreTable) ->
		table = []
		for response in scoreTable
			console.log(response.type)
			if response.type != "SCORE_FINAL_FROM_CLIENT"
				question = $scope.getQuestion(qset, response.data[1])
				if question
					items = question.options.items || null 
					gainedItems = if items.some((i) => i.count > 0) then true else false
					lostItems = if items.some((i) => i.count < 0) then true else false
					row =
						question: response.data[0]
						answer: response.data[2]
						feedback: response.feedback
						items: items
						gainedItems: gainedItems
						lostItems: lostItems
					table.push(row)
		return table

	$scope.getScoreFinal = (scoreTable) ->
		table = []
		for response in scoreTable
			if response.type == "SCORE_FINAL_FROM_CLIENT"
				table.push(response.data[0])
		return table


	$scope.toggleInventoryDrawer = () ->
		$scope.showInventory = !$scope.showInventory
	
	materiaCallbacks.start = (instance, qset, scoreTable, isPreview, qsetVersion) ->
		$scope.$apply -> 
			console.log(qset)
			console.log(scoreTable)
			if parseInt(qsetVersion) is 1 then qset = JSON.parse legacyQsetSrv.convertOldQset qset
			console.log(qset)
			$scope.inventory = $scope.createInventoryFromResponses(qset, scoreTable)
			$scope.itemSelection = qset.options.inventoryItems || []
			$scope.table = $scope.createTable(qset, scoreTable)
			$scope.scoreFinalTable = $scope.getScoreFinal(scoreTable)
			console.log($scope.itemSelection.length)
			console.log($scope.scoreFinalTable)
			console.log($scope.table)
			
	Materia.ScoreCore.hideResultsTable()

	return Materia.ScoreCore.start materiaCallbacks

]