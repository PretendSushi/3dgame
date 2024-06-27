extends Control

@onready var quest_container = $VBoxContainer/QuestContainer
@onready var quest_name = $VBoxContainer/QuestContainer/QuestName
@onready var quest_step = $VBoxContainer/QuestContainer/QuestStep
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_update_quest_log(quest):
	if quest_container != null:
		var new_quest = quest_container.duplicate()
		new_quest.get_child(0).text = quest.quest_name
		for step in quest.steps:
			new_quest.get_child(1).text = step.text
