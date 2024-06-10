extends Control

@onready var attr_container = $HBox
@onready var attr = $HBox/Attribute
@onready var attr_label = $HBox/Attribute/Container/Label

const MAX_ATTR_LEVEL = 20

signal point_add(attr)
signal point_sub(attr)

var is_arr_ready = false
var attr_arr = []
var init_attr_values = []
# Called when the node enters the scene tree for the first time.
func _ready():
	attr_arr.push_back(_create_attr("Strength"))
	attr_arr.push_back(_create_attr("Reflexes"))
	attr_arr.push_back(_create_attr("Charisma"))
	attr_arr.push_back(_create_attr("Constitution"))
	attr_arr.push_back(_create_attr("Intelligence"))
	attr_arr.push_back(_create_attr("Perception"))
	
	attr.hide()
	
	for attr in attr_arr:
		attr_container.add_child(attr)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_arr_ready:
		if attr_arr.size() > 0:
			for i in range(attr_arr.size()):
				attr_arr[i].get_child(1).text = str(init_attr_values[i])
			is_arr_ready = true

func _create_attr(attr_name):
	var new_attr = attr.duplicate()
	new_attr.get_child(0).get_child(1).text = attr_name
	new_attr.name = attr_name
	var minus = new_attr.get_child(0).get_child(0)
	var plus = new_attr.get_child(0).get_child(2)
	minus.pressed.connect(_on_button_pressed.bind(attr_name, minus, plus))
	plus.pressed.connect(_on_button_2_pressed.bind(attr_name, minus, plus))	
	return new_attr


func _on_button_pressed(attr : String, minus, plus):
	emit_signal("point_sub", attr)
	var curr_attr_total = _inc_attr_point(attr, false)
	if curr_attr_total == 0:
		minus.disabled = true
	else:
		minus.disabled = false
	plus.disabled = false
	
func _on_button_2_pressed(attr : String, minus, plus):
	emit_signal("point_add", attr)
	var curr_attr_total = _inc_attr_point(attr, true)
	if curr_attr_total == MAX_ATTR_LEVEL:
		plus.disabled = true
	else:
		plus.disabled = false
	minus.disabled = false
	


func _on_player_initialize_char_sheet(attr_value_arr):
	init_attr_values = attr_value_arr
	
func _inc_attr_point(target_attr, increment):
	for attr in attr_arr:
		if attr.get_child(0).get_child(1).text == target_attr:
			if increment:
				attr.get_child(1).text = str(int(attr.get_child(1).text) + 1)
			else:
				attr.get_child(1).text = str(int(attr.get_child(1).text) - 1)
			return int(attr.get_child(1).text)
