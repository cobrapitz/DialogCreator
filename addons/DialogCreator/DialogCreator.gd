extends Control
tool

const VERSION = str("[center]Version - %s[/center]" % str(0.1))

var version_label

var sidebar
var hide_sidebar_button
var show_sidebar_button

var graph_edit : GraphEdit

var comment_node
var event_node
var message_node
var condition_node
var entry_node
var exit_node

var load_button
var save_button
var language_button

var added_node
var dragging = false

var Nodes = {
	"Entry" : preload("res://addons/DialogCreator/Nodes/GraphNodeStart.tscn"),
	"Exit" : preload("res://addons/DialogCreator/Nodes/GraphNodeStart.tscn"),
	"Comment" : preload("res://addons/DialogCreator/Nodes/GraphNodeStart.tscn"),
	"Event" : preload("res://addons/DialogCreator/Nodes/GraphNodeStart.tscn"),
	"Condition" : preload("res://addons/DialogCreator/Nodes/GraphNodeStart.tscn"),
	"Message" : preload("res://addons/DialogCreator/Nodes/GraphNodeStart.tscn"),
}


func _enter_tree():
	graph_edit = find_node("GraphEdit")
	
	sidebar = find_node("Sidebar")
	show_sidebar_button = find_node("ShowSidebar")
	hide_sidebar_button = find_node("HideSidebar")
	version_label = find_node("VersionLabel")
	
	comment_node = find_node("Comment")
	event_node = find_node("Event")
	message_node = find_node("Message")
	condition_node = find_node("Condition")
	entry_node = find_node("Entry")
	exit_node = find_node("Exit")
	
	save_button = find_node("Save")
	load_button = find_node("Load")
	language_button = find_node("Language")
	
	version_label.bbcode_text = VERSION
	show_sidebar_button.hide()
	
	load_button.connect("pressed", self, "_load_pressed")
	save_button.connect("pressed", self, "_save_pressed")
	language_button.connect("item_selected", self, "_language_selected")
	
	comment_node.connect("button_down", self, "_on_comment_button_down")
	event_node.connect("button_down", self, "_on_event_button_down")
	message_node.connect("button_down", self, "_on_message_button_down")
	condition_node.connect("button_down", self, "_on_condition_button_down")
	entry_node.connect("button_down", self, "_on_entry_button_down")
	exit_node.connect("button_down", self, "_on_exit_button_down")
	
	hide_sidebar_button.connect("pressed", self, "_hide_sidebar_pressed")
	show_sidebar_button.connect("pressed", self, "_show_sidebar_pressed")


func _exit_tree() -> void:
	pass


func _process(delta: float) -> void:
	if dragging:
		#print("dragging, ", graph_edit.get_local_mouse_position())
		added_node.offset = get_local_mouse_position() + graph_edit.scroll_offset
		added_node.offset.x -= added_node.rect_size.x
		added_node.offset.y -= added_node.rect_size.y * 0.5


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == false:
			if dragging:
				added_node.selected = false
				dragging = false


func _on_entry_button_down():
	added_node = Nodes.Entry.instance()
	graph_edit.add_child(added_node)
	dragging = true


func _on_exit_button_down():
	added_node = Nodes.Exit.instance()
	graph_edit.add_child(added_node)
	dragging = true


func _on_comment_button_down():
	added_node = Nodes.Comment.instance()
	graph_edit.add_child(added_node)
	dragging = true


func _on_event_button_down():
	added_node = Nodes.Event.instance()
	graph_edit.add_child(added_node)
	dragging = true


func _on_message_button_down():
	added_node = Nodes.Message.instance()
	graph_edit.add_child(added_node)
	dragging = true


func _on_condition_button_down():
	added_node = Nodes.Condition.instance()
	graph_edit.add_child(added_node)
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
	print("load")


func _save_pressed():
	print("save")


func _language_selected(id):
	print("language id ", id)


func _on_GraphEdit_gui_input(event: InputEvent) -> void:
	pass
