extends GraphNode
class_name GraphNodeBase
tool

var id : int
var next


func _enter_tree():
	if not is_connected("resize_request", self, "_on_graphNode_resize_request"):
		connect("resize_request", self, "_on_graphNode_resize_request")
		connect("close_request", self, "_on_graphNode_close_request")


func _on_graphNode_resize_request(new_minsize):
	var ratios = []
	var expands = 0
	
	if new_minsize.y < rect_min_size.y:
		new_minsize.y = rect_min_size.y
	
	rect_size = new_minsize
	
	get_child(0).rect_size = rect_size - Vector2(20, -20)
	get_child(0).rect_position = Vector2(20, -20)


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
	
	for field in get_children():
		print("todo save children")
		pass
	
	return data


func load_data(data : Dictionary):
	for key in data.internal:
		pass
	for field in data.internal.fields:
		#add_field()
		print(field, " -> ", data.internal[field])
#		data[field].load_data(data)


func get_field_idx(idx : int):
	return get_child(idx)


func _set_frame_color(color : Color):
	var frame = get("custom_styles/frame").duplicate()
	set("custom_styles/frame", frame)
	get("custom_styles/frame").set("border_color", color)

