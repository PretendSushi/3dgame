extends Node

class_name Step

var text : String
var completed : bool

signal step_completed()

func _init(txt):
	text = txt
	completed = false

func _step_completed():
	completed = true
	

## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
