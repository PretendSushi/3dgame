extends Node2D

@onready var choice_button_scn = preload("res://Scenes/ChoiceButton.tscn")

var choice_buttons: Array[Button] = []

func _clear_dialgoue_box():
	$VBoxContainer/Text.text = ""
	for choice in choice_buttons:
		$VBoxContainer.remove_child(choice)
	choice_buttons = []

func _add_text(text: String):
	$VBoxContainer/Text.text = text
	
func _add_choice(choice_text: String):
	var button_obj: ChoiceButton = choice_button_scn.instantiate()
	button_obj.choice_index = choice_buttons.size()
	choice_buttons.push_back(button_obj)
	button_obj.text = choice_text
	button_obj.choice_selected.connect(_on_choice_selected)
	$VBoxContainer.add_child(button_obj)

func _on_choice_selected(choice_index: int):
	($EzDialogue as EzDialogue).next(choice_index)
	print(choice_index)

# Called when the node enters the scene tree for the first time.
func _ready():
#	_add_choice("this is choice number 0")
#	_add_choice("this is choice number 1")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ez_dialogue_dialogue_generated(response: DialogueResponse):
	_clear_dialgoue_box()
	
	_add_text(response.text)
	for choice in response.choices:
		_add_choice(choice)
