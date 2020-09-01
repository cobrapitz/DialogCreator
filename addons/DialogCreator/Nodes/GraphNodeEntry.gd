extends DefaultGraphNode
tool

signal on_deletion




func _ready():
	pass


func _enter_tree() -> void:
	connect("close_request", self, "_on_graphNodeStart_close_request")


func get_save_data() -> Dictionary:
	var data = {}
	
	data["meta"] = {}
	data["internal"] = {}
	
	data.meta["offsetx"] = offset.x
	data.meta["offsety"] = offset.y
	
	data.internal["type"] = title
	data.internal["next"] = next
	data.internal["id"] = id
	
	return data


func set_from_load_data(data : Dictionary):
	offset.x = data.meta.offsetx
	offset.y = data.meta.offsety
	
	title = data.internal.type
	id = data.internal.id
	next = data.internal.next


func _on_graphNodeStart_close_request():
	queue_free()


func _on_graphNodeStart_resize_request(new_minsize):
	rect_size = new_minsize
	print(rect_size)


func set_entry_point(id):
	$hBoxContainer/entry.text = str(id)


func get_entry():
	return $hBoxContainer/entry.text


func _on_GraphNodeEntry_resize_request(new_minsize: Vector2) -> void:
	rect_size = new_minsize
