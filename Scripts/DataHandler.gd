extends Node

var item_data := {}
var item_grid_data := {}
@onready var item_data_path = "res://Data/Item_data.json"

var weapons = load("res://Scenes/Weapons.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_data(item_data_path)
	_set_grid_data()
	_set_weapon_ids()

func _load_data(a_path) -> void:
	if not FileAccess.file_exists(a_path):
		print("FNF")
	var item_data_file = FileAccess.open(a_path, FileAccess.READ)
	
	item_data = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()

func _set_grid_data():
	for item in item_data.keys():
		var temp_grid_array := []
		for point in item_data[item]["Grid"].split("/"):
			temp_grid_array.push_back(point.split(","))
		item_grid_data[item] = temp_grid_array
		
func _set_weapon_ids():
	for i in range(1,(item_data.size()+1)):
		for weapon in weapons.instantiate().get_children():
			if item_data[str(i)]["Name"] == weapon.get_name():
				weapon.weapon_id = i
				
func _get_weapon_by_id(item_id):
	if item_id == null:
		return null
	for i in range(1, (item_data.size()+1)):
		if item_data[str(i)]["IsWeapon"] == false:
			continue
		else:
			if i == item_id:
				return item_data[str(i)]
				
