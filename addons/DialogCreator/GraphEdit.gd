extends GraphEdit
tool


var start_node

func _ready():
	pass


func _enter_tree() -> void:
	init()
	connect_signals()


func _exit_tree() -> void:
	pass


### INIT

func _process(delta: float) -> void:
	pass


func init():
	pass


func connect_signals():
	return
	connect("_begin_node_move", self, "_begin_node_move")
	connect("_end_node_move", self, "_end_node_move")
	connect("connection_from_empty", self, "connection_from_empty")
	connect("connection_request", self, "connection_request")
	connect("connection_to_empty", self, "connection_to_empty")
	connect("copy_nodes_request", self, "copy_nodes_request")
	connect("delete_nodes_request", self, "delete_nodes_request")
	connect("disconnection_request", self, "disconnection_request")
	connect("duplicate_nodes_request", self, "duplicate_nodes_request")
	connect("node_selected", self, "node_selected")
	connect("node_unselected", self, "node_unselected")
	connect("paste_nodes_request", self, "paste_nodes_request")
	connect("popup_request", self, "popup_request")


#### CONNECTIONS


func connection_from_empty(to: String, to_slot: int, release_position: Vector2) -> void:
	pass


func connection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	pass


func connection_to_empty(from: String, from_slot: int, release_position: Vector2) -> void:
	print("from: ", from)


func popup_request(position: Vector2) -> void:
	pass


func paste_nodes_request() -> void:
	pass


func node_unselected(node: Node) -> void:
	pass


func node_selected(node: Node) -> void:
	pass


func duplicate_nodes_request() -> void:
	pass


func disconnection_request(from: String, from_slot: int, to: String, to_slot: int) -> void:
	pass


func copy_nodes_request() -> void:
	pass


func delete_nodes_request() -> void:
	pass


func _begin_node_move() -> void:
	pass


func _end_node_move() -> void:
	pass
