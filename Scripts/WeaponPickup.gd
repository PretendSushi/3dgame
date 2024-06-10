extends RigidBody3D

@onready var weapon_mesh = $Cube_007
@onready var weapon_collision = $CollisionShape3D

@export var item_id : int
@export var weapon_name: String
@export var current_ammo: int
@export var reserve_ammo: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_interact_attempt(item):
	if typeof(item) == TYPE_INT && item == item_id:
		weapon_mesh.visible = false# Replace with function body.
		weapon_collision.visible = false
