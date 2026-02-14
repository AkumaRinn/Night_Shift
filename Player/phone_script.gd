extends Control

@onready var logsList = $LogsPage/ScrollContainer/LogsList

func on_save_logs(savedLogs: Array[SavedLogs]):
	var allLogs = logsList.get_children()
	
	for element in allLogs:
		var logData = SavedLogs.new()
		var hContainer = element.get_node("HBoxContainer")
		logData.anomaly_name = hContainer.get_node("EntryTitle").text
		logData.anomaly_details = hContainer.get_node("EntryText").text
		savedLogs.append(logData)
	
