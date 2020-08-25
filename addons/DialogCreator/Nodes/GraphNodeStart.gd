extends GraphNode
tool
var _type


func _on_graphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_graphNode_close_request():
	queue_free()


func set_type(type):
	_type = type


func get_type():
	return _type


signal on_deletion

var next


func _ready():
	pass


func _enter_tree() -> void:
	connect("close_request", self, "_on_graphNodeStart_close_request")


func _on_graphNodeStart_close_request():
	queue_free()


func _on_graphNodeStart_resize_request(new_minsize):
	rect_size = new_minsize


func set_entry_point(id):
	$hBoxContainer/entry.text = str(id)


func get_entry():
	return $hBoxContainer/entry.text


func _on_GraphNodeStart_dragged(from: Vector2, to: Vector2) -> void:
	pass
