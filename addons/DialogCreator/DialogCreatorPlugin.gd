tool
extends EditorPlugin


const MainPanel = preload("res://addons/DialogCreator/DialogCreator.tscn")

var main_panel_instance


func _enter_tree():
	main_panel_instance = MainPanel.instance()
	
	if get_editor_interface().get_editor_viewport().has_node("DialogCreator"):
		var n = get_editor_interface().get_editor_viewport().get_node("DialogCreator")
		n.name = "mehl1"
		n.queue_free()
	
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance, true)
	main_panel_instance.owner = get_editor_interface().get_editor_viewport()
	
	main_panel_instance.init()
	
	# Hide the main panel. Very much required.
	make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "Dialog Creator"


func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("GraphEdit", "EditorIcons")
