extends Control

@onready var slot_scene = preload("res://Scenes/slot.tscn")
@onready var grid_container = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var item_scene = preload("res://Scenes/Item.tscn")
@onready var scroll_container = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer
@onready var weapon_grid1 = $WeaponInventory/MarginContainer/VBoxContainer3/Weapon1Container/WeaponContainer1
@onready var weapon_grid2 = $WeaponInventory/MarginContainer/VBoxContainer3/Weapon2Container/WeaponContainer2
@onready var col_count = grid_container.columns
@onready var col_count_weapon = weapon_grid1.columns

var inv_open = false

const GRID_SIZE = 64
const WEAPON_GRID_SIZE = 12

var grid_array := []
var weapon_grid_array_slot1 := []
var weapon_grid_array_slot2 := []
var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2

signal weapon_changed(weapon_id, slot)
signal clean_slots(slots)


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(GRID_SIZE):
		_create_slots(grid_container, grid_array)
	for i in range(WEAPON_GRID_SIZE):
		_create_slots(weapon_grid1, weapon_grid_array_slot1)
	for i in range(WEAPON_GRID_SIZE):
		_create_slots(weapon_grid2, weapon_grid_array_slot2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if !inv_open:
			inv_open = true
		elif inv_open:
			inv_open = false
	var a_Grid
	if current_slot != null:
		a_Grid = _find_grid(current_slot.get_parent())
	if a_Grid == null:
		a_Grid = grid_array
	if item_held:
		if Input.is_action_just_pressed("right_click"):
			_rotate_item(a_Grid)
		if Input.is_action_just_pressed("left_click"):
#			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
			_place_item(a_Grid, current_slot.get_parent(), _find_column_count(current_slot.get_parent()))
			if a_Grid == weapon_grid_array_slot1 or a_Grid == weapon_grid_array_slot2:
				var slot
				match a_Grid:
					weapon_grid_array_slot1:
						slot = "slot1"
					weapon_grid_array_slot2:
						slot = "slot2"
				emit_signal("weapon_changed", _get_weapon_in_slot(a_Grid), slot)
				emit_signal("clean_slots", [_get_weapon_in_slot(weapon_grid_array_slot1), _get_weapon_in_slot(weapon_grid_array_slot2)])
				
				
	else:
		if Input.is_action_just_pressed("left_click"):
			if inv_open:
	#			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
				_pick_up_item(a_Grid, _find_column_count(current_slot.get_parent()))
		

func _create_slots(container,array):
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = array.size()
	array.push_back(new_slot)
	container.add_child(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(a_Slot, container):
	var a_Grid = _find_grid(container)
	icon_anchor = Vector2(10000,10000)
	current_slot = a_Slot
	if item_held:
		_check_slot_availability(current_slot,a_Grid, _find_column_count(container))
		_set_grids.call_deferred(current_slot, a_Grid, _find_column_count(container))

func _on_slot_mouse_exited(a_Slot):
	_clear_grid(grid_array)
	_clear_grid(weapon_grid_array_slot1)
	_clear_grid(weapon_grid_array_slot2)
	
func _on_button_spawn_pressed():
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item._load_item(randi_range(1,4))
	new_item.selected = true
	item_held = new_item
	
func _check_slot_availability(a_Slot, a_Grid, columns):
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * columns
		var line_switch_check = a_Slot.slot_ID % columns + grid[0]
		if line_switch_check < 0 or line_switch_check >= columns:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= a_Grid.size():
			can_place = false
			return
		if a_Grid[grid_to_check].state == a_Grid[grid_to_check].State.TAKEN:
			can_place = false
			return
	can_place = true
	
func _set_grids(a_Slot, a_Grid, columns):
	for  grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * columns
		var line_switch_check = a_Slot.slot_ID % columns + grid[0]
		if grid_to_check < 0 or grid_to_check >= a_Grid.size():
			continue
		if line_switch_check < 0 or line_switch_check >= columns:
			continue
		
		if can_place:
			a_Grid[grid_to_check]._set_colour(a_Grid[grid_to_check].State.FREE)
			if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
		else:
			a_Grid[grid_to_check]._set_colour(a_Grid[grid_to_check].State.TAKEN)
		
		if a_Grid == weapon_grid_array_slot1 and !_is_weapon_slot_available(a_Grid):
			a_Grid[grid_to_check]._set_colour(a_Grid[grid_to_check].State.TAKEN)

func _clear_grid(a_Grid):
	for grid in a_Grid:
		grid._set_colour(grid.State.DEFAULT)

func _rotate_item(a_Grid):
	item_held._rotate_item(a_Grid)
	_clear_grid(a_Grid)
	if current_slot:
		_on_slot_mouse_entered(current_slot, current_slot.get_parent())
		
func _place_item(a_Grid, container, columns):
	if not can_place or not current_slot:
		return
				
	if a_Grid == weapon_grid_array_slot1 or a_Grid == weapon_grid_array_slot2:
		if !_is_weapon_slot_available(a_Grid):
			return
		
	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * col_count + icon_anchor.y
	item_held._snap_to(a_Grid[calculated_grid_id].global_position)
	
	item_held.get_parent().remove_child(item_held)
	container.add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	item_held.grid_anchor = current_slot
	for grid in item_held.item_grids:
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * columns
		a_Grid[grid_to_check].state = a_Grid[grid_to_check].State.TAKEN
		a_Grid[grid_to_check].item_stored = item_held
		
	item_held = null
	_clear_grid(a_Grid)
	_is_weapon_slot_available(weapon_grid_array_slot1)
	
func _pick_up_item(a_Grid, columns):
	if not current_slot or not current_slot.item_stored:
		return
	
	item_held = current_slot.item_stored
	item_held.selected = true
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * columns
		a_Grid[grid_to_check].state = a_Grid[grid_to_check].State.FREE 
		a_Grid[grid_to_check].item_stored = null
		
	_check_slot_availability(current_slot, a_Grid, columns)
	_set_grids.call_deferred(current_slot)

func _add_to_inventory(item):
	grid_container.add_child(item)

func _on_player_interact_attempt(item_id):
	if item_id != null && typeof(item_id) == TYPE_INT:
		var new_item = item_scene.instantiate()
		add_child(new_item)
		new_item._load_item(item_id)
		new_item.selected = true
		item_held = new_item
		new_item.item_ID = item_id
		_add_to_inventory(item_held)
		
func _find_grid(container):
	var a_Grid
	match container:
		grid_container:
			a_Grid = grid_array
		weapon_grid1:
			a_Grid = weapon_grid_array_slot1
		weapon_grid2:
			a_Grid = weapon_grid_array_slot2
	return a_Grid
	
func _find_column_count(container):
	var columns
	match container:
		grid_container:
			columns = col_count
		weapon_grid1, weapon_grid2:
			columns = col_count_weapon 
	return columns
	
func _is_weapon_slot_available(a_Grid):
	for grid in a_Grid:
		if grid.state == grid.State.TAKEN:
			return false
	return true
	
func _get_weapon_in_slot(a_Grid):
	for grid in a_Grid:
		if "item_stored" not in grid:
			continue
		if grid.item_stored == null:
			continue
		else:
			return grid.item_stored.item_ID
	return null
	
