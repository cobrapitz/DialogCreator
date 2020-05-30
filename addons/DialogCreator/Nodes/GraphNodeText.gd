extends "res://Previous/DefaultGraphNode.gd"


signal on_language_changed(id, languageAbbreviation)


onready var bustNames = $VBoxContainer/HBoxContainer/VBoxContainer2/BustName
onready var bustExpressions = $VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression

var next

var _speakerId = 0

# languages
var texts = {}
var busts = {}


func _ready():
	if texts.has(TranslationServer.get_locale()):
		$text.text = texts[TranslationServer.get_locale()]


func set_speaker_suggestions(suggestions : Array):
	for i in range(suggestions.size()):
		$hBoxContainer/speaker.add_item(suggestions[i])


func set_bust_suggestions(suggestions : Dictionary):
	for bustName in suggestions:
		var expressionNames = suggestions[bustName]
		$VBoxContainer/HBoxContainer/VBoxContainer2/BustName.add_item(bustName)
		busts[bustName] = expressionNames
	
	if !suggestions.empty():
		_on_BustName_item_selected(0)


func set_speaker(speaker):
	if speaker == "{player}":
		_on_player_pressed()
	elif speaker == "{partner}":
		_on_dialogPartner_pressed()
	elif speaker != "":
		for i in range($hBoxContainer/speaker.get_item_count()):
			if $hBoxContainer/speaker.get_item_text(i) == speaker:
				$hBoxContainer/speaker.disabled = false
				$hBoxContainer/speaker.select(i)
		_on_custom_pressed()


func get_speaker():
	if $player.pressed:
		return "{player}"
	elif $dialogPartner.pressed:
		return "{partner}"
	elif $hBoxContainer/custom.pressed:
		return $hBoxContainer/speaker.get_item_text(_speakerId)
	return ""


func select_bust(bustName : String, bustExpression : String):
	if bustName.empty() or bustExpression.empty():
		$VBoxContainer/EnableBust.pressed = false
	else:
		$VBoxContainer/EnableBust.pressed = true
	_on_EnableBust_pressed()
	
	for i in range($VBoxContainer/HBoxContainer/VBoxContainer2/BustName.get_item_count()):
		if $VBoxContainer/HBoxContainer/VBoxContainer2/BustName.get_item_text(i) == bustName:
			$VBoxContainer/HBoxContainer/VBoxContainer2/BustName.select(i)
			break
	
	for i in range($VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.get_item_count()):
		if $VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.get_item_text(i) == bustExpression:
			$VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.select(i)
			break


func get_bust_name() -> String:
	if !$VBoxContainer/EnableBust.disabled:
		return $VBoxContainer/HBoxContainer/VBoxContainer2/BustName.text
	return ""


func get_bust_expression() -> String:
	if !$VBoxContainer/EnableBust.disabled:
		return $VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.text
	return ""


func set_text(language : String, text : String):
	texts[language] = text


func update_text(language : String):
	if texts.has(language):
		$text.text = texts[language]
	else:
		$text.text = ""


func get_text(language : String = "DE"):
	return texts[language]


func get_texts() -> Dictionary:
	return texts


func _on_custom_pressed():
	$hBoxContainer/speaker.disabled = false
	$dialogPartner.pressed = false
	$player.pressed = false
	$hBoxContainer/custom.pressed = true


func _on_dialogPartner_pressed():
	$dialogPartner.pressed = true
	$player.pressed = false
	$hBoxContainer/custom.pressed = false
	$hBoxContainer/speaker.disabled = true


func _on_player_pressed():
	$dialogPartner.pressed = false
	$player.pressed = true
	$hBoxContainer/custom.pressed = false
	$hBoxContainer/speaker.disabled = true


func _on_speaker_item_selected(ID):
	_speakerId = ID
	_on_custom_pressed()


func _on_EnableBust_pressed():
	if $VBoxContainer/EnableBust.pressed:
		if busts.size() > 1:
			if $VBoxContainer/HBoxContainer/VBoxContainer2/BustName.selected == 0:
				$VBoxContainer/HBoxContainer/VBoxContainer2/BustName.select(1)
				_on_BustName_item_selected(1) 
				$VBoxContainer/HBoxContainer/VBoxContainer2/BustName.select(0)
				_on_BustName_item_selected(0)
			else:
				$VBoxContainer/HBoxContainer/VBoxContainer2/BustName.select(0)
				_on_BustName_item_selected(0)
				
		$VBoxContainer/HBoxContainer/VBoxContainer2/BustName.disabled = false
		$VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.disabled = false
	else:
		$VBoxContainer/HBoxContainer/VBoxContainer2/BustName.text = ""
		$VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.text = ""
		$VBoxContainer/HBoxContainer/VBoxContainer2/BustName.disabled = true
		$VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.disabled = true


func _on_BustName_item_selected(id):
	var bustName = $VBoxContainer/HBoxContainer/VBoxContainer2/BustName.get_item_text(id)
	$VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.clear()
	
	for idx in busts[bustName]:
		var expr = busts[bustName][idx]
		$VBoxContainer/HBoxContainer/VBoxContainer2/FacialExpression.add_item(expr)


func _on_Language_item_selected(id):
	emit_signal("on_language_changed", id, $Language.get_item_text(id))


func _on_text_text_changed():
	texts[$Language.get_item_text($Language.selected)] = $text.text
