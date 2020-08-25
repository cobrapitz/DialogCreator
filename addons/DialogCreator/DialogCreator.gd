extends Control
tool


func _enter_tree():
	print("ready")
	$Toolbar/NewNode.connect("pressed", self, "_new_node_pressed")
	$Toolbar/Load.connect("pressed", self, "_load_pressed")
	$Toolbar/Save.connect("pressed", self, "_save_pressed")
	$Toolbar/Language.connect("item_selected", self, "_language_selected")


func _exit_tree() -> void:
	pass


func _new_node_pressed():
	print("new node")


func _load_pressed():
	print("load")


func _save_pressed():
	print("save")


func _language_selected(id):
	print("language id ", id)

