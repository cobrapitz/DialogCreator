extends TextEdit
tool



func init_field(data):
	text = data


func get_save_data():
	return {"text": text}


func load_data(data):
	text = data.text
