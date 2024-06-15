extends Node3D

@onready var ui = $UI

@onready var death_screen = $UI/DeathScreen
@onready var hit_rect = $UI/HitRect
@onready var inventory = $UI/Inventory

@onready var crosshair = $UI/Crosshair
@onready var hit_mark = $UI/Hitmarker
@onready var pause_menu = $UI/pauseMenu
@onready var hud = $UI/HUD
@onready var char_man = $UI/CharacterManager
@onready var char_sheet = $UI/CharacterSheet
@onready var dialogue_box = $UI/Dialogue

@export var dialogue_json : JSON
@onready var state = {}

var is_inv_open = false
var is_ads = false
var is_paused = false

signal lock_dialogue
signal unlock_dialogue

# Called when the node enters the scene tree for the first time.
func _ready():
	crosshair.position.x = get_viewport().size.x / 2 - 32
	crosshair.position.y = get_viewport().size.y / 2 - 32
	hit_mark.position.x = get_viewport().size.x / 2 - 32
	hit_mark.position.y = get_viewport().size.y / 2 - 32
	
#	dialogue_json.resource_path = "res://Data/Dialogues/test.json"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		if is_inv_open:
			inventory.visible = false
			char_sheet.visible = false
		if !is_inv_open: 
			inventory.visible = true
			
		crosshair.visible = !crosshair.visible
		hud.visible = !hud.visible
		is_inv_open = !is_inv_open
		char_man.visible = !char_man.visible
			
		
	if Input.is_action_just_pressed("right_click"):
		crosshair.visible = false
		
	if Input.is_action_just_released("right_click"):
		if !is_inv_open:
			crosshair.visible = true
	
	if Input.is_action_just_pressed("pause"):
		_pause_menu()

func _pause_menu():
	if is_paused:
		pause_menu.hide()
		Engine.time_scale = 1
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		pause_menu.show()
		Engine.time_scale = 0
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	is_paused = !is_paused

func _on_player_player_hit():
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func _on_generic_soldier_enemy_hit():
	hit_mark.visible = true
	await get_tree().create_timer(0.05).timeout
	hit_mark.visible = false


func _on_player_player_death():
	var ui_elements = ui.get_children()
	for element in ui_elements:
		element.visible = false
	death_screen.visible = true
	Engine.time_scale = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func _on_npc_load_dialogue(dialogue):
	dialogue = load("res://Data/Dialogues/" + dialogue)
	dialogue_json = dialogue
	($UI/Dialogue/EzDialogue as EzDialogue).start_dialogue(dialogue_json, state)
	dialogue_box.visible = true
	emit_signal("lock_dialogue")

func _on_dialogue_end_of_dialogue():
	await get_tree().create_timer(2.0).timeout
	dialogue_box.visible = false
	emit_signal("unlock_dialogue")
