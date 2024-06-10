class_name ChoiceButton extends Button

@onready var choice_index: int


signal choice_selected(choice_index)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	choice_selected.emit(choice_index)
 
