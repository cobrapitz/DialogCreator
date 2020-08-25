extends GraphEdit
tool

var start_node

func _ready():
	init()
	connect_signals()


func _enter_tree() -> void:
	pass


func _exit_tree() -> void:
	pass


### INIT


func init():
	pass


func connect_signals():
	if connect("_begin_node_move", self, "_begin_node_move") != OK: 
		print_debug("couldn't find func 1")
	if connect("_end_node_move", self, "_end_node_move") != OK: 
		print_debug("couldn't find func 1")
	if connect("connection_from_empty", self, "connection_from_empty") != OK: 
		print_debug("couldn't find func 1")
	if connect("connection_request", self, "connection_request") != OK: 
		print_debug("couldn't find func 1")
	if connect("connection_to_empty", self, "connection_to_empty") != OK: 
		print_debug("couldn't find func 1")
	if connect("copy_nodes_request", self, "copy_nodes_request") != OK: 
		print_debug("couldn't find func 1")
	if connect("delete_nodes_request", self, "delete_nodes_request") != OK: 
		print_debug("couldn't find func 1")
	if connect("disconnection_request", self, "disconnection_request") != OK: 
		print_debug("couldn't find func 1")
	if connect("duplicate_nodes_request", self, "duplicate_nodes_request") != OK: 
		print_debug("couldn't find func 1")
	if connect("node_selected", self, "node_selected") != OK: 
		print_debug("couldn't find func 1")
	if connect("node_unselected", self, "node_unselected") != OK: 
		print_debug("couldn't find func 1")
	if connect("paste_nodes_request", self, "paste_nodes_request") != OK: 
		print_debug("couldn't find func 1")
	if connect("popup_request", self, "popup_request") != OK: 
		print_debug("couldn't find func 1")


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
