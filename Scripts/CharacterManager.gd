extends Control

@onready var inv = $"../Inventory"
@onready var char_sheet = $"../CharacterSheet"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_inventory_pressed():
	inv.visible = true
	char_sheet.visible = false
	


func _on_character_sheet_pressed():
	inv.visible = false
	char_sheet.visible = true
