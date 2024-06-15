extends Node

class_name Quest

var quest_dir = "res://Data/Quests/"

var quest_name : String
#all the steps to complete the quest
var steps = []
#index of current step in the array
var curr_step : int
#is the quest completed?
var completed

func _init(filename):
	if not FileAccess.file_exists(quest_dir + filename):
		print("FNF")
	var quest_file = FileAccess.open(quest_dir + filename, FileAccess.READ)
	
	var quest_data = JSON.parse_string(quest_file.get_as_text())
	quest_file.close()
	
	quest_name = quest_data["name"]
	
	for step in quest_data["steps"]:
		steps.push_back(Step.new(step))
	
func _step_completed():
	steps[curr_step].completed = true
	if curr_step == steps.size():
		completed = true
	else:
		curr_step += 1

## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
