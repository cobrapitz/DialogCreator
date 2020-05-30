extends DefaultGraphNode

signal on_language_changed(id, languageAbbreviation)
signal on_option_language_changed(id, languageAbbreviation)


var _choicesAmount = 1
var _speakerId = 0
var texts := {}
var optionTexts := {}


func _ready():
	$choice/Language.connect("item_selected", self, "_on_Option_Language_item_selected", [$choice/Language])
	$choice/lineEdit.connect("text_changed", self, "_on_option_text_changed", [$choice/lineEdit])
	_on_Language_item_selected(1)


func _on_button_pressed():
	_spawn_choice()


func set_speaker_suggestions(suggestions : Array):
	for i in range(suggestions.size()):
		$HBoxContainer/Speaker.add_item(suggestions[i])


func _spawn_choice():
	var additionalChoices = $additionalChoice
	remove_child($additionalChoice)
	var newChoice = $choice.duplicate()
	optionTexts[str(_choicesAmount)] = {}
	newChoice.get_node("choiceNumber").text = str(_choicesAmount)
	newChoice.get_node("lineEdit").text = ""
	newChoice.get_node("lineEdit").connect("text_changed", self, "_on_option_text_changed", [newChoice.get_node("lineEdit")])
	newChoice.get_node("Language").connect("item_selected", self, "_on_Option_Language_item_selected", [newChoice.get_node("Language")])
	add_child(newChoice)
	add_child(additionalChoices)
	set_slot(get_child_count() - 2, false, -1, Color.white, true, 0, Color(1, 0, 1, 1))
	
	_choicesAmount += 1


func set_text(language : String, text : String):
	texts[language] = text


func update_text(language : String):
	if texts.has(language):
		$text.text = texts[language]
	else:
		$text.text = ""


func get_text(language : String = "DE"):
	if $EnableText.pressed:
		return texts[language]
	else:
		return "" # text disabled


func get_texts() -> Dictionary:
	return texts


func set_speaker(speaker : String):
	if speaker == "": # no speaker set
		$EnableSpeaker.pressed = false
		_on_EnableSpeaker_pressed()
		return
	else:
		$EnableSpeaker.pressed = true
		_on_EnableSpeaker_pressed()
		
	if speaker == "{player}":
		_on_Player_pressed()
	elif speaker == "{partner}":
		_on_Partner_pressed()
	elif speaker != "":
		for i in range($HBoxContainer/Speaker.get_item_count()):
			if $HBoxContainer/Speaker.get_item_text(i) == speaker:
				$HBoxContainer/Speaker.disabled = false
				$HBoxContainer/Speaker.select(i)
		_on_Custom_pressed()


func get_speaker() -> String:
	if $EnableSpeaker.pressed:
		if $Player.pressed:
			return "{player}"
		elif $Partner.pressed:
			return "{partner}"
		elif $HBoxContainer/Custom.pressed:
			return $HBoxContainer/Speaker.get_item_text(_speakerId)
	return "" # disabled speaker


func get_decision_text(choice):
	return optionTexts[str(choice)]


func get_decision_amount():
	return _choicesAmount


func add_choice(choiceNumber, data, choiceNext):
	if str(choiceNumber) != "0":
		_spawn_choice()
	
	optionTexts[str(choiceNumber)] = {}
	for lan in data:
		optionTexts[str(choiceNumber)][lan] = data[lan]
	
	var lastChoice = get_child(get_child_count() - 2)
	lastChoice.get_node("choiceNumber").text = str(choiceNumber)
	lastChoice.get_node("lineEdit").text = data[TranslationServer.get_locale()]


func set_choice_text(idx : int, language : String, text : String):
	get_child(10 + idx).get_node("lineEdit").text = text
	optionTexts[str(idx)][language] = text


func update_choice(idx : int, language : String):
	if optionTexts[str(idx)].has(language):
		get_child(10 + idx).get_node("lineEdit").text = optionTexts[str(idx)][language]
	else:
		optionTexts[str(idx)][language] = ""
		get_child(10 + idx).get_node("lineEdit").text = ""


func _on_EnableSpeaker_pressed():
	if $EnableSpeaker.pressed:
		$Player.show()
		$Partner.show()
		$HBoxContainer.show()
		$text.show()
		$questionDescription.show()
		$EnableText.pressed = true
	else:
		$Player.hide()
		$Partner.hide()
		$HBoxContainer.hide()


func _on_Player_pressed():
	$Player.pressed = true
	$Partner.pressed = false
	$HBoxContainer/Custom.pressed = false


func _on_Custom_pressed():
	$HBoxContainer/Speaker.disabled = false
	$Player.pressed = false
	$Partner.pressed = false
	$HBoxContainer/Custom.pressed = true


func _on_Partner_pressed():
	$Player.pressed = false
	$Partner.pressed = true
	$HBoxContainer/Custom.pressed = false


func _on_EnableText_pressed():
	if $EnableText.pressed:
		$text.show()
		$questionDescription.show()
	else:
		$text.hide()
		$questionDescription.hide()
		$Player.hide()
		$Partner.hide()
		$HBoxContainer.hide()
		$EnableSpeaker.pressed = false


func _on_Speaker_item_selected(ID):
	_speakerId = ID
	_on_Custom_pressed()


func _on_Option_Language_item_selected(id, opt):
	emit_signal("on_option_language_changed", opt.get_parent().get_index() - 10, opt.get_item_text(id))


func _on_option_text_changed(text, node):
	optionTexts[node.get_parent().get_node("choiceNumber").text]\
			[node.get_parent().get_node("Language").get_item_text( \
			node.get_parent().get_node("Language").selected)] = text


func _on_Language_item_selected(id):
	emit_signal("on_language_changed", id, $Language.get_item_text(id))


func _on_text_text_changed():
	texts[$Language.get_item_text($Language.selected)] = $text.text
