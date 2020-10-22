extends GraphNode
class_name DefaultGraphNode
tool

var next : Array = []
var id : int

var _fields = {}


func _enter_tree():
	if not is_connected("resize_request", self, "_on_graphNode_resize_request"):
		connect("resize_request", self, "_on_graphNode_resize_request")
		connect("close_request", self, "_on_graphNode_close_request")


func _on_graphNode_resize_request(new_minsize):
	var ratios = []
	var expands = 0
	
	if new_minsize.y < rect_min_size.y:
		new_minsize.y = rect_min_size.y
	
	var total = new_minsize.y - 70.0
	
	for child in get_children():
		ratios.append(child.rect_min_size.y / rect_size.y)
		if child.is_in_group("expands"):
			expands += 1
		else:
			total -= child.rect_size.y
	
	rect_size = new_minsize
	
	for idx in range(get_child_count()):
		if get_child(idx).is_in_group("expands"):
			get_child(idx).rect_min_size.y = 1.0 / expands * total
	


func _on_graphNode_close_request():
	queue_free()


func get_save_data() -> Dictionary:
	var data = {}
	
	data.meta = {}
	data.meta.offsetx = offset.x
	data.meta.offsety = offset.y
	
	data.internal = {}
	data.internal.type = title
	data.internal.next = next
	data.internal.id = id
	data.internal.fields = {}
	
	for field_name in _fields:
		data.internal.fields[field_name] = _fields[field_name].get_save_data()
	
	return data


func load_data(data : Dictionary):
	for key in data.internal:
		pass
	for field in data.internal.fields:
		#add_field()
		print(field, " -> ", data.internal[field])
#		data[field].load_data(data)


func get_field(key : String):
	print("added fields: ", _fields)
	return _fields[key]


func get_field_idx(idx : int):
	return get_child(idx)


func _set_frame_color(color : Color):
	var frame = get("custom_styles/frame").duplicate()
	set("custom_styles/frame", frame)
	get("custom_styles/frame").set("border_color", color)


func add_field(node_data):
	for field_key in node_data.keys():
		if field_key == "Meta":
			continue
		
		var field_data = node_data[field_key]
		
		var field_type = field_data.FieldType
		var slot = field_data.Slot.to_lower()
		var default_value = field_data.Default
		var input_color = field_data.InputColor
		var output_color = field_data.OutputColor
		
		input_color = Color(input_color[0], input_color[1], input_color[2])
		output_color = Color(output_color[0], output_color[1], output_color[2])
		
		var new_field = find_parent("DialogCreator").NODE_FIELDS[field_type].instance()
		
		var has_input = "i" in slot
		var has_output = "o" in slot
		
		new_field.init_field(default_value)
	
		add_child(new_field, true)
		_fields[field_type] = new_field
		new_field.set_owner(self)
		
		set("slot/%d/left_enabled" % (get_child_count()-1), has_input)
		set("slot/%d/right_enabled" % (get_child_count()-1), has_output)
		
		set("slot/%d/left_color" % (get_child_count()-1), input_color)
		set("slot/%d/right_color" % (get_child_count()-1), output_color)
		
		rect_min_size.y += new_field.rect_size.y
		_on_graphNode_resize_request(rect_min_size)
	
