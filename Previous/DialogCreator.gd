extends Control

# prefabs
const textPrefab = preload("Nodes/GraphNodeText.tscn")
const eventPrefab = preload("Nodes/GraphNodeEvent.tscn")
const decisionPrefab = preload("Nodes/GraphNodeDecision.tscn")
const endPrefab = preload("Nodes/GraphNodeEnd.tscn")
const startPrefab = preload("Nodes/GraphNodeStart.tscn")

# data from files
export(String, FILE) var npcFile
export(String, FILE) var dataFilePath
export(String, FILE) var bustFilePath


onready var popup : Popup = get_node("menuButton").get_popup()
onready var dialogSelector : Popup = get_node("loadedDialogsSelection").get_popup()
onready var graphEdit : GraphEdit = get_node("graphEdit")

var npcData = []
var _data = {}
var bustData = {}

# used when loading
#var _allDialogs = {}
var _allConnections = []

var _selected = null
var _lastFile = ""
var _loadMode = false

var _entryAmount = 1
var _entryMap = {}

var nodeSpawn = Vector2(90.0, 90.0)
var nodesIndex = 0
var connections = []

# new
var _loadedDialogs

var _nodeIds = 0
var _entryIds = 0
var _allNodes = {}


func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,SceneTree.STRETCH_ASPECT_EXPAND, Vector2(0,0))
	set_process_input(true)
	popup.connect("id_pressed", self, "_on_item_pressed")
	dialogSelector.connect("id_pressed", self, "_on_loadedDialogsSelection_item_selected")
	_load_data()
	
	$fileDialog.current_path = ProjectSettings.globalize_path("res://Data/")


func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE): 
		$fileDialog.hide()
		$saveFileDialog.hide()


func _load_data():
	# NPC speaker (names)
	var file = File.new()
	file.open(npcFile, file.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	
	for i in range(fileContent.size()):
		npcData.append(fileContent[fileContent.keys()[i]].name)
	
	
	# EVENT data
	var dataFile = File.new()
	dataFile.open(dataFilePath, dataFile.READ)
	var dataFileContent = parse_json(dataFile.get_as_text())
	dataFile.close()
	
	for i in range(dataFileContent.size()):
		var key = dataFileContent.keys()[i]
		_data[key] = {}
		_data[key].data = dataFileContent[key].data
		_data[key].slider = dataFileContent[key].slider
	
	
	# BUST DATA
	var bustFile = File.new()
	bustFile.open(bustFilePath, bustFile.READ)
	var bustFileContent = parse_json(bustFile.get_as_text())
	bustFile.close()
	
	for bustName in bustFileContent:
		var data = bustFileContent[bustName]
		bustData[bustName] = {}
		for idx in data:
			var expressionName = data[idx]
			bustData[bustName][idx] = expressionName


func _on_item_pressed(id):
	_create_node(popup.get_item_text(id))


func _load_language_text(id : int, languageAbbr : String, node):
	node.update_text(languageAbbr)


func _on_option_language_changed(id, langAbb, node):
	node.update_choice(id, langAbb)


func _on_language_changed(id, langAbb, node):
	node.update_text(langAbb)


func _create_node(type, size = Vector2(-1.0, -1.0), position = $graphEdit.scroll_offset + Vector2(OS.get_window_size().x / 2.8,OS.get_window_size().y / 2), values = {}):
	var prefab
	
	if not values.empty():
		if int(values["nodesIndex"]) > nodesIndex:
			nodesIndex = int(values["nodesIndex"])
	
	match (type):
		"Text":
			prefab = textPrefab.instance()
			prefab.set_speaker_suggestions(npcData)
			prefab.set_bust_suggestions(bustData)
			prefab.connect("on_language_changed", self, "_load_language_text", [prefab])
			if not values.empty():
				prefab.set_speaker(values.speaker)
				if typeof(values.text) == TYPE_DICTIONARY:
					for key in values.text:
						prefab.set_text(key, values.text[key])
				else:
					prefab.set_text("en", values.text)
					
				if values.has("bust_name") and values.has("bust_expression"):
					prefab.select_bust(values.bust_name, values.bust_expression)
				else:
					prefab.select_bust("", "")
			
		"Decision":
			prefab = decisionPrefab.instance()
			prefab.set_speaker_suggestions(npcData)
			prefab.connect("on_language_changed", self, "_on_language_changed", [prefab])
			prefab.connect("on_option_language_changed", self, "_on_option_language_changed", [prefab])
			if not values.empty():
				if typeof(values.text) == TYPE_DICTIONARY:
					for key in values.text:
						prefab.set_text(key, values.text[key])
				else:
					prefab.set_text("en", values.text)
					
				prefab.set_speaker(values.speaker)
				for i in range(values.choices.size()):
					var next = values.choices[str(i)].next
					prefab.add_choice(i, values.choices[str(i)].text, next)
				
		"Event":
			prefab = eventPrefab.instance()
			for key in _data:
				prefab.set_item_suggestions(key, _data[key].data, _data[key].slider)
					
			var entries = []
			for i in range($startNode.get_popup().get_item_count()):
				entries.append($startNode.get_popup().get_item_text(i))
			prefab.set_item_suggestions("Set Entry", entries)
			if not values.empty():
				prefab.set_selected_item(values.event_type, values)
				_allConnections.append([str(values["nodesIndex"]), 0, values.next_success, 0])
				_allConnections.append([str(values["nodesIndex"]), 1, values.next_failure, 0])
			
		"End":
			prefab = endPrefab.instance()
			
		"Entry Point":
			prefab = startPrefab.instance()
			prefab.connect("on_deletion", self, "_remove_entry_id")
			
			if $startNode.disabled:
				$startNode.disabled = false
			
			if not values.empty():
				prefab.set_entry_point(values.entry)
				if _entryIds <= int(values.entry):
					_entryIds = int(values.entry) + 1
			else:
				prefab.set_entry_point(_entryIds)
				$startNode.add_item(str(_entryIds), _entryIds)
				_entryMap[str(_entryIds)] = $startNode.get_popup().get_item_count()-1
				_entryIds += 1
		_:
			printerr("not recognized dialog type!")
	
	if not values.empty():
		prefab.name = str(values["nodesIndex"])
	else:
		prefab.name = str(_nodeIds)
		_nodeIds += 1
	
	prefab.offset = position
		
	if size.x != -1.0 and size.y != -1.0:
		prefab.rect_size = size
		
	prefab.set_type(type)

	if not values.empty():
		if _nodeIds <= int(values["nodesIndex"]):
			_nodeIds = int(values["nodesIndex"]) + 1
	
	graphEdit.add_child(prefab)
	_allNodes[prefab.name] = prefab

	if type == "Entry Point":
		for i in range($graphEdit.get_child_count()):
			var child = $graphEdit.get_child(i)
			if child.get_class() == "GraphNode" and child.get_type() == "Event":
				var entries = []
				for i in range($startNode.get_popup().get_item_count()):
					entries.append($startNode.get_popup().get_item_text(i))
				child.clear_item_suggestions("Set Entry")
				child.set_item_suggestions("Set Entry", entries, 0)
#				if child.get_selected_key() == "Set Entry":
#					child.set_selected("Set Entry")


func _on_graphNodeText_close_request():
#	print("close")
	pass


func _on_graphNodeText_raise_request():
#	print("raise")
	pass


func _on_graphNodeText_dragged(from, to):
#	print("fromto")
#	print(from)
#	print(to)
	pass


func _remove_entry_id(id):
	for i in range($startNode.get_item_count()):
		if $startNode.get_item_text(i) == id:
			var sel = $startNode.get_selected_id()
			$startNode.remove_item(i)
			_entryMap.erase(id)
	
			if sel != $startNode.get_selected_id():
				if $startNode.get_item_count() > 0:
					$startNode.select(0)
					$startNode.text = $startNode.get_item_text(0)
				else:
					$startNode.text = ""
			else:
				$startNode.text = ""
			break


func _on_graphEdit_connection_request(from, from_slot, to, to_slot):
	if $graphEdit.connect_node(from, from_slot, to, to_slot) != OK:
		print("connection not ok")


func _on_graphEdit_connection_to_empty(from, from_slot, release_position):
#	print("empty")
	pass


func _on_graphEdit_disconnection_request(from, from_slot, to, to_slot):
	for i in range(_allConnections.size()):
		var con = _allConnections[i]
		if con[0] == str(from) and con[1] == from_slot and con[2] == str(to) and con[3] == to_slot:
			_allConnections.remove(i)
			
			for i in range(_allNodes.size()):
				if _allNodes[_allNodes.keys()[i]].name == from:
					# TODO add function to give node name and slot to remove connection
					if _allNodes[_allNodes.keys()[i]]._type == "Decision":
						break
					
					_allNodes[_allNodes.keys()[i]].next = ""
			
			break
		#_allConnections.append([str(c-1), 0, dial.next, 0])
	$graphEdit.disconnect_node(from, from_slot, to, to_slot)


func _on_graphEdit_delete_nodes_request():
	pass


func _on_graphEdit_duplicate_nodes_request():
#	if _selected != null:
#		if _selected.title == "Start Node":
#			return
#		var newNode = _selected.duplicate()
#		newNode.offset += Vector2(25.0, 25.0)
#		newNode.name += str(nodesIndex)
#		graphEdit.add_child(newNode)
#		nodesIndex += 1
	pass


func _on_graphEdit_node_selected(node):
	_selected = node


func _on_save_pressed():
	# file dialog 
	_loadMode = false
	$saveFileDialog.show()
	$saveFileDialog.set_current_dir($fileDialog.get_current_dir())


func _on_load_pressed():
	# file dialog 
	_loadMode = true
	$fileDialog.show()
	print($fileDialog.get_current_dir())
	$fileDialog.set_current_dir($fileDialog.get_current_dir())


func _on_saveFileDialog_file_selected(filePath):
	_lastFile = filePath
	
	if $graphEdit.get_child_count() <= 2:
		return
	
	# load current file
	var file = File.new()
	var fileContent
	if file.open(filePath, file.READ) == OK:
		var text = file.get_as_text()
		fileContent = parse_json(text)
	file.close()
	
	var dialogData = fileContent
	
	if dialogData == null:
		dialogData = {}
	
	var currentBegin = ""
	
	var newConversation = {}
	
	for i in range($graphEdit.get_child_count()):
		if not "@@" in $graphEdit.get_child(i).name and $graphEdit.get_child(i).name != "CLAYER":
			var node = _allNodes[$graphEdit.get_child(i).name]
			var type = node.get_type()
			
			var newDialog = {}
			newDialog["type"] = type
			newDialog["x"] = node.offset.x
			newDialog["y"] = node.offset.y
			newDialog["w"] = node.rect_size.x
			newDialog["h"] = node.rect_size.y
			
			match (type):
				"Entry Point":
					newDialog["entry"] = node.get_entry()
					newDialog["next"] = ""
					var connectionList = $graphEdit.get_connection_list()
					for i in range(connectionList.size()):
						var connection = connectionList[i]
						var from = connection[connection.keys()[0]]
						var to = connection[connection.keys()[2]]
						if from == node.name:
							newDialog["next"] = to
							if currentBegin == "":
								currentBegin = str(from)
				
				"Decision":
					newDialog["text"] = node.get_texts()
					newDialog["speaker"] = node.get_speaker()
					var choices = {}
					for i in range(node.get_decision_amount()):
						var decisionText = node.get_decision_text(i)
						var connectionList = $graphEdit.get_connection_list()
						var next
						for k in range(connectionList.size()):
							var connection = connectionList[k]
							var from = connection[connection.keys()[0]]
							var to = connection[connection.keys()[2]]
							if from == node.name:
								if connection[connection.keys()[1]] == i:
									next = to
						choices[str(i)] = { "next" : str(next), "text" : decisionText}
					newDialog["choices"] = choices
					
				"End":
					pass
					
				"Text":
					newDialog["speaker"] = node.get_speaker()
					newDialog["text"] = node.get_texts()
					newDialog["bust_name"] = node.get_bust_name()
					newDialog["bust_expression"] = node.get_bust_expression()
					newDialog["next"] = ""
					var connectionList = $graphEdit.get_connection_list()
					for i in range(connectionList.size()):
						var connection = connectionList[i]
						var from = connection[connection.keys()[0]]
						var to = connection[connection.keys()[2]]
						if from == node.name:
							newDialog["next"] = to
					
				"Event":
					newDialog["event_type"] = node.get_event_type()
					var next_success = ""
					var next_failure = ""
					var connectionList = $graphEdit.get_connection_list()
					for i in range(connectionList.size()):
						var connection = connectionList[i]
						var from = connection[connection.keys()[0]]
						var to = connection[connection.keys()[2]]
						if from == node.name:
							if connection[connection.keys()[1]] == 0:
								next_success = to
							else:
								next_failure = to
					var event_params = {}
					for i in range(node.get_event_param_amount()):
						var val = node.get_event_param(i)
						event_params[str(i)] = val

					newDialog["event_params"] = event_params
					newDialog["next_success"] = next_success
					newDialog["next_failure"] = next_failure
				
				_:
					print("type doens't exist: " + str(node["type"]))
			newConversation[node.name] = newDialog
	newConversation["currentBegin"] = currentBegin	
	
	dialogData[$dialogNameEdit.text] = newConversation
	file.open(filePath, file.WRITE)
	file.store_string(to_json(dialogData))
	file.close()


func _on_FileDialog_file_selected(filePath):
	_lastFile = filePath
	# load
	$loadedDialogsSelection.get_popup().clear()
	$loadedDialogsSelection.disabled = false
	
	clear_all()
	# load dialogs
	var file = File.new()
	file.open(_lastFile, file.READ)
	var text = file.get_as_text()
	_loadedDialogs = parse_json(text)
	file.close()

	for i in range(_loadedDialogs.size()):
		$loadedDialogsSelection.get_popup().add_item(_loadedDialogs.keys()[i])

	if _loadedDialogs.size() == 1:
		_load_conversation(_loadedDialogs.keys()[0])


func _load_conversation(conversation):
	# load all dialogs
	var conv = _loadedDialogs[conversation]
	
	for c in conv:
		var dial = conv[c]
		if typeof(dial) == TYPE_STRING:
			continue
		if dial.type == "Entry Point":
			$startNode.add_item(str(dial.entry), int(dial.entry))
	
	for c in range(conv.size()):
		var dial = conv[conv.keys()[c]]
		if conv.keys()[c] == "currentBegin":
			continue
		var arr = {}
		if dial.type != "Decision" and dial.type != "End" and dial.type != "Event":
			arr["next"] = dial.next
			_allConnections.append([str(conv.keys()[c]), 0, dial.next, 0])
		elif dial.type == "Decision":
			for key in dial.choices:
				_allConnections.append([str(conv.keys()[c]), int(key), dial.choices[key].next, 0])
		
		match (dial.type):
			"Entry Point":
				arr["entry"] = dial.entry
			"Decision":
				arr["text"] = dial.text
				arr["speaker"] = dial.speaker
				arr["choices"] = dial.choices
			"End":
				pass
			"Text":
				arr["speaker"] = dial.speaker
				arr["text"] = dial.text
				
				if dial.has("bust_name"):
					arr["bust_name"] = dial.bust_name
				else:
					arr["bust_name"] = ""
				
				if dial.has("bust_expression"):
					arr["bust_expression"] = dial.bust_expression
				else:
					arr["bust_expression"] = ""
			"Event":
				arr["event_type"] = dial.event_type
				arr["event_params"] = dial.event_params
				arr["next_success"] = dial.next_success
				arr["next_failure"] = dial.next_failure
			_:
				print("type doens't exist: " + str(dial["type"]))
		arr["nodesIndex"] = str(conv.keys()[c])
		if dial.has("w") and dial.has("h"):
			_create_node(dial.type, Vector2(float(dial.w), float(dial.h)), Vector2(float(dial.x), float(dial.y)), arr)
		else:
			_create_node(dial.type, Vector2(-1.0, -1.0), Vector2(float(dial.x), float(dial.y)), arr)
		
	for i in range(_allConnections.size()):
		var con = _allConnections[i]
		if con[2] == "":
			continue
		if con[2] == "Null" or con[0] == null or con[1] == null or con[3] == null:
			continue
		if not _allNodes.has(str(con[0])) or not _allNodes.has(str(con[2])):
			continue
		
		$graphEdit.connect_node(_allNodes[str(con[0])].name, con[1], _allNodes[str(con[2])].name, con[3])
		
		#$graphEdit.connect_node(int(_allNodes[str(con[0])].name), int(con[1]), int(_allNodes[str(con[2])].name), int(con[3]))


func clear_all():
	var it = 0
	for i in range($graphEdit.get_child_count()):
		if not "@@" in $graphEdit.get_child(it).name and $graphEdit.get_child(it).name != "CLAYER":
			var child = $graphEdit.get_child(it)
			$graphEdit.remove_child(child)
			child.queue_free()
		else:
			it += 1
			
	$graphEdit.clear_connections()
	$startNode.clear()
	$startNode.disabled = true
	_nodeIds = 0
	_entryIds = 0
	nodesIndex = 0
	_allConnections.clear()
	_allNodes.clear()


func _on_deleteAll_pressed():
	clear_all()


func _on_loadedDialogsSelection_item_selected(ID):
	clear_all()
	var conversation = $loadedDialogsSelection.get_popup().get_item_text(ID)
	_load_conversation(conversation)
	$dialogNameEdit.text = conversation
