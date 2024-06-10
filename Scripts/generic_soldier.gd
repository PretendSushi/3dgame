extends CharacterBody3D


var player = null
var state_machine
var health = 100

signal enemy_hit
signal enemy_killed

const SPEED = 1.75
const ATTACK_RANGE = 2.5

@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"WalkForward":
			nav_agent.target_position = player.global_transform.origin
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)
			
		"Fire":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/walk", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	
	move_and_slide()
	
func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
func _hit_finished():
	if (global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0):
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir, 25)

func _on_area_3d_body_part_hit(dam):
	health -= dam
	emit_signal("enemy_hit")
	anim_tree.set("parameters/conditions/hit", true)
	await get_tree().create_timer(0.4).timeout
	anim_tree.set("parameters/conditions/hit", false)
	if(health <= 0):
		queue_free()
		emit_signal("enemy_killed")
		
