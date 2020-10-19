extends HBoxContainer
tool


func init_field(data):
	$Label.text = data


func get_save_data():
	return {"checked": $CheckButton.pressed}


func load_data(data):
	$CheckButton.pressed = data.checked
