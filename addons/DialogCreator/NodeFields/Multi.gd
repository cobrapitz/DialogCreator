extends VBoxContainer
tool

var _node_field_template
var _fields = []



func init_field(data):
	_node_field_template = data.template


func _enter_tree():
	$Add.connect("pressed", self, "_add_pressed")


func get_fields() -> Array:
	return _fields


func set_field_template(template):
	_node_field_template = template


func _add_pressed():
	var dialog_creator = find_parent("DialogCreator")
	
	if _node_field_template == null:
		printerr("no template supplied.")
		return
	
	if dialog_creator == null:
		printerr("parent 'DialogCreator' not found")
		return
	
	var new_field = dialog_creator.NODE_FIELDS[_node_field_template].instance()
	
	add_child(new_field, true)
	move_child(new_field, 0)
	
	_fields.append(new_field)
