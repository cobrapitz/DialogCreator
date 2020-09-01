extends GraphNode
class_name DefaultGraphNode

var next : Array = []
var id : int


func _ready():
	pass


func _on_graphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_graphNode_close_request():
	queue_free()


func get_save_data() -> Dictionary:
	print("no overwrite")
	return {}


func set_from_load_data(data : Dictionary):
	print("no overwrite")

