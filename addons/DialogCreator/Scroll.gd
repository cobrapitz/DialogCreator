extends Control
tool


var _start_mouse_position
var _start_graph_position

var _dialog_creator


func init():
	_dialog_creator = find_parent("DialogCreator")
	rect_global_position = _dialog_creator.graph_edit.rect_global_position
	rect_size = _dialog_creator.graph_edit.rect_size
	
	rect_global_position += Vector2(0, 0)
	rect_size -= Vector2(11, 10)


func _input(event: InputEvent) -> void:
	if is_visible_in_tree():
		if !Rect2(rect_global_position, rect_size).has_point(get_global_mouse_position()):
			return
		if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			if _start_mouse_position == null:
				_start_mouse_position = get_global_mouse_position()
				_start_graph_position = _dialog_creator.graph_edit.scroll_offset
			
			_dialog_creator.graph_edit.scroll_offset = _start_graph_position + \
					_start_mouse_position - get_global_mouse_position()
		else:
			_start_mouse_position = null
		
		if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
			accept_event()
			_dialog_creator.graph_edit.zoom += 0.1
		if Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
			accept_event()
			_dialog_creator.graph_edit.zoom -= 0.1

