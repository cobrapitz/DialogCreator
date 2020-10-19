extends Button
tool

var _node_template_data
var _fields = []



func init_field(data):
	_node_template_data = data


func _enter_tree():
	connect("pressed", self, "_add_pressed")


func get_save_data() -> Dictionary:
	var data = {}
	
	data.TemplateFieldType = _node_template_data.TemplateFieldType
	data.Slot = _node_template_data.Slot
	data.Default = _node_template_data.Default
	data.InputColor = _node_template_data.InputColor
	data.OutputColor = _node_template_data.OutputColor
	data.Fields = {}
	
	for field in _fields:
		data.Fields[str(data.Fields.size())] = field.get_save_data()
	
	return data


func load_data(data):
	_node_template_data.TemplateFieldType = data.TemplateFieldType
	_node_template_data.Slot = data.Slot
	_node_template_data.Default = data.Default
	_node_template_data.InputColor = data.InputColor
	_node_template_data.OutputColor = data.OutputColor
	
	var dialog_creator = find_parent("DialogCreator")
	
	for field in data.Fields:
		var new_field = dialog_creator.NODE_FIELDS[_node_template_data.TemplateFieldType].instance()
		new_field.load_data(data.Fields[field])


func get_fields() -> Array:
	return _fields


#func set_field_template(template, slot_type):
#	_node_field_template = template
#	_node_field_slot_type = slot_type


func _add_pressed():
	var dialog_creator = find_parent("DialogCreator")
	
	if _node_template_data == null:
		printerr("no template supplied.")
		return
	
	if dialog_creator == null:
		printerr("parent 'DialogCreator' not found")
		return
	
	var new_field = dialog_creator.NODE_FIELDS[_node_template_data.TemplateFieldType].instance()
	
	new_field.init_field(_node_template_data.Default)
	
	get_parent().add_child(new_field, true)
	get_parent().move_child(new_field, get_position_in_parent())
	
	var graph_node : GraphNode = get_parent()
	
	var input_color = Color(
			_node_template_data.InputColor[0], 
			_node_template_data.InputColor[1], 
			_node_template_data.InputColor[2])
	
	var output_color = Color(
			_node_template_data.OutputColor[0], 
			_node_template_data.OutputColor[1], 
			_node_template_data.OutputColor[2])
	
	graph_node.set_slot(get_position_in_parent() - 1, 
			_node_template_data.Slot.find("i") != -1, 0, input_color, 
			_node_template_data.Slot.find("o") != -1, 0, output_color)
	
	for slot_idx in range(graph_node.get_child_count() - (get_position_in_parent() + 1)):
		var curr = graph_node.get_child_count() - slot_idx - 1
		var prev = graph_node.get_child_count() - slot_idx - 2
		graph_node.set_slot(curr, 
				graph_node.is_slot_enabled_left(prev), graph_node.get_slot_type_left(prev), 
				graph_node.get_slot_color_left(prev), 
				graph_node.is_slot_enabled_right(prev), graph_node.get_slot_type_right(prev), 
				graph_node.get_slot_color_right(prev))
	
	
	_fields.append(new_field)
