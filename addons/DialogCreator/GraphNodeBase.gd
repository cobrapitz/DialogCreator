tool
extends GraphNode


func _ready():
	connect_signals()


func connect_signals():
	if connect("close_request", self, "close_request") != OK: 
		print_debug("couldn't find func 1")
	if connect("dragged", self, "dragged") != OK: 
		print_debug("couldn't find func 1")
	if connect("offset_changed", self, "offset_changed") != OK: 
		print_debug("couldn't find func 1")
	if connect("raise_request", self, "raise_request") != OK: 
		print_debug("couldn't find func 1")
	if connect("resize_request", self, "resize_request") != OK: 
		print_debug("couldn't find func 1")


func close_request() -> void:
	print("close req")


func dragged(from: Vector2, to: Vector2) -> void:
	print("dragged")


func offset_changed() -> void:
	print("offset changed")


func raise_request() -> void:
	print("raise req")


func resize_request(new_minsize: Vector2) -> void:
	print("resize req")
