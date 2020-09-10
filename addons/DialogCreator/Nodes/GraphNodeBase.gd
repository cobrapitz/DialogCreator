extends GraphNode
class_name DefaultGraphNode
tool

var next : Array = []
var id : int

var _fields = {}


func _enter_tree():
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
	print("no overwrite")
	return {}


func set_from_load_data(data : Dictionary):
	print("no overwrite")


func get_field(key : String):
	print("added fields: ", _fields)
	return _fields[key]


func get_field_idx(idx : int):
	return get_child(idx)


func _set_frame_color(color : Color):
	var frame = get("custom_styles/frame").duplicate()
	set("custom_styles/frame", frame)
	get("custom_styles/frame").set("border_color", color)


func add_field(field_name : String, new_field, \
		has_input = false, has_output = false, input_color = Color.green, output_color = Color.red):
	add_child(new_field, true)
	_fields[field_name] = new_field
	
	set("slot/%d/left_enabled" % (get_child_count()-1), has_input)
	set("slot/%d/right_enabled" % (get_child_count()-1), has_output)
	
	set("slot/%d/left_color" % (get_child_count()-1), input_color)
	set("slot/%d/right_color" % (get_child_count()-1), output_color)
	
	rect_min_size.y += new_field.rect_size.y
	_on_graphNode_resize_request(rect_min_size)

