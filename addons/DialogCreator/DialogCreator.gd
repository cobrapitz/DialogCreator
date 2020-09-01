extends Control
tool

const VERSION = str("[center]Version - 1.0[/center]")

var version_label

var sidebar
var hide_sidebar_button
var show_sidebar_button

var graph_edit : GraphEdit

var node_button_container

var load_button
var save_button
var language_button

var save_dialog_popup : FileDialog
var load_dialog_popup : FileDialog

var added_node
var added_nodes = []
var dragging = false

var Nodes = {
	"Entry" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Message" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Exit" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Event" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Condition" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Choice" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Signal" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Sound" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Music" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Random Choice" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
	"Comment" : preload("res://addons/DialogCreator/Nodes/GraphNodeEntry.tscn"),
}

var _unique_node_id = 0

var mouse_inside_graph_edit = false

func _ready():
	pass


func _enter_tree():
	graph_edit = find_node("GraphEdit")
	
	sidebar = find_node("Sidebar")
	show_sidebar_button = find_node("ShowSidebar")
	hide_sidebar_button = find_node("HideSidebar")
	version_label = find_node("VersionLabel")
	
	node_button_container = find_node("NodeButtonsContainer")
	
	save_button = find_node("Save")
	load_button = find_node("Load")
	language_button = find_node("Language")
	
	load_dialog_popup = find_node("LoadFileDialog") as FileDialog
	save_dialog_popup = find_node("SaveFileDialog") as FileDialog
	
	load_dialog_popup.access = FileDialog.ACCESS_FILESYSTEM
	load_dialog_popup.add_filter("*.json")
	load_dialog_popup.mode = FileDialog.MODE_OPEN_FILE
	save_dialog_popup.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog_popup.add_filter("*.json")
	save_dialog_popup.mode = FileDialog.MODE_SAVE_FILE
	
	version_label.bbcode_text = VERSION
	show_sidebar_button.hide()
	
	load_button.connect("pressed", self, "_load_pressed")
	save_button.connect("pressed", self, "_save_pressed")
	language_button.connect("item_selected", self, "_language_selected")
	
	save_dialog_popup.connect("file_selected", self, "_on_save_file_selected")
	load_dialog_popup.connect("file_selected", self, "_on_load_file_selected")
	
	for child in node_button_container.get_children():
		node_button_container.remove_child(child)
		child.free()
	
	for key in Nodes.keys():
		var button = Button.new()
		node_button_container.add_child(button)
		button.owner = self
		button.text = key
		button.set("custom_styles/normal", preload("res://addons/DialogCreator/Styles/DC_SidebarNodeButtonStyle.tres"))
		button.size_flags_horizontal = button.SIZE_EXPAND_FILL
		button.size_flags_vertical = button.SIZE_EXPAND_FILL
		button.connect("button_down", self, "_on_node_button_down", [key])
	
	hide_sidebar_button.connect("pressed", self, "_hide_sidebar_pressed")
	show_sidebar_button.connect("pressed", self, "_show_sidebar_pressed")
	
	graph_edit.connect("mouse_entered", self, "_on_GraphEdit_mouse_entered")
	graph_edit.connect("mouse_exited", self, "_on_GraphEdit_mouse_exited")


func _exit_tree() -> void:
	pass


func _process(delta: float) -> void:
	if dragging:
		#print("dragging, ", graph_edit.get_local_mouse_position())
		added_node.offset = get_local_mouse_position() + graph_edit.scroll_offset
		added_node.offset.x -= added_node.rect_size.x
		added_node.offset.y -= added_node.rect_size.y * 0.5
		
		added_node.offset.x /= graph_edit.snap_distance
		added_node.offset.y /= graph_edit.snap_distance
		added_node.offset.x = int(added_node.offset.x) * graph_edit.snap_distance
		added_node.offset.y = int(added_node.offset.y) * graph_edit.snap_distance
		
		added_node.offset *= 1 / graph_edit.zoom
		


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == false:
			if dragging:
				added_node.selected = false
				dragging = false
	
	if is_visible_in_tree() and mouse_inside_graph_edit:
		if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
			graph_edit.zoom += 0.1
			accept_event()
		if Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
			graph_edit.zoom -= 0.1
			accept_event()


func save_dialog(path : String):
	print("saving file to: ", path)
	
	var data = _get_save_data()
	
	var file = File.new()
	file.open(path, File.WRITE_READ)
	file.store_string(data)
	file.close()


func load_dialog(path : String):
	print("loading file from: ", path)
	
	clear_existing_nodes()
	
	var file = File.new()
	file.open(path, File.READ)
	var data = JSON.parse(file.get_as_text())
	file.close()
	
	if data.error != OK:
		printerr("Couldn't load file: ", path)
		return
	data = data.result
	
	# editor settings
	graph_edit.zoom = data.editor.zoom
	graph_edit.scroll_offset.x = data.editor.scrollx
	graph_edit.scroll_offset.y = data.editor.scrolly
	
	_unique_node_id = 0
	for key in data.internal.keys():
		var node_data = {}
		node_data["meta"] = data.meta[key]
		node_data["internal"] = data.internal[key]
		
		var node = create_new_node(data.internal[key].type)
		node.set_from_load_data(node_data)
		
		var id = int(data.internal[key].id)
		if id >= _unique_node_id:
			_unique_node_id = id + 1
	print("new id: ", _unique_node_id)


func _get_save_data() -> String:
	var data = {}
	
	data["meta"] = {}
	data["internal"] = {}
	data["editor"] = {}
	
	# editor settings
	data.editor["zoom"] = graph_edit.zoom
	data.editor["scrollx"] = graph_edit.scroll_offset.x
	data.editor["scrolly"] = graph_edit.scroll_offset.y
	
	for node in added_nodes:
		var node_data = node.get_save_data()
		data.meta[node.id] = node_data.meta
		data.internal[node.id] = node_data.internal
	
	return JSON.print(data)


func clear_existing_nodes():
	for node in added_nodes:
		node.get_parent().remove_child(node)
		node.queue_free()


# SIGNALS


func create_new_node(type : String):
	added_node = Nodes[type].instance()
	graph_edit.add_child(added_node)
	added_nodes.append(added_node)
	return added_node


func _on_node_button_down(type : String):
	if not Nodes.has(type):
		print("Node type %s doesn't exist!" % type)
		return
	
	added_node = create_new_node(type)
	added_node.id = _unique_node_id
	_unique_node_id += 1
	dragging = true


func _show_sidebar_pressed():
	sidebar.show()
	show_sidebar_button.hide()


func _hide_sidebar_pressed():
	show_sidebar_button.show()
	sidebar.hide()


func _new_node_pressed():
	print("new node")


func _load_pressed():
	load_dialog_popup.popup()


func _save_pressed():
	save_dialog_popup.popup()


func _language_selected(id):
	print("language id ", id)


func _on_save_file_selected(path: String) -> void:
	save_dialog(path)


func _on_load_file_selected(path: String) -> void:
	load_dialog(path)


func _get_move_input() -> Vector2:
	return Vector2(
			int(Input.is_action_pressed("key_right")) - int(Input.is_action_pressed("key_left")),
			int(Input.is_action_pressed("key_down")) - int(Input.is_action_pressed("key_up")))



func _on_GraphEdit_mouse_entered() -> void:
	mouse_inside_graph_edit = true


func _on_GraphEdit_mouse_exited() -> void:
	mouse_inside_graph_edit = false

