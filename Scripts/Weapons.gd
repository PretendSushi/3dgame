extends Node3D

class_name Weapon

#class meta data
var weapon_name: String
var base_damage: float
var damage: float
var condition: int
var ammo_type: String
enum FireRate {AUTO, SEMI, ACTION}
var fire_rate
var weapon_id

#state 
var is_ads = false

#object components
@onready var gun_anim = $AnimationPlayer
@onready var gun_barrel = $RayCast3D
var bullet = load("res://Scenes/bullet.tscn")
var instance

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_L):
		print(gun_barrel.position)
		print(gun_barrel.get_parent().position)
		print(gun_barrel.get_parent().name)
	
func _shoot(aim_ray):
	if !gun_anim.is_playing():
		if !is_ads:
			gun_anim.play("shoot")
		else:
			gun_anim.play("ads_shoot")
		if aim_ray.is_colliding():
			if aim_ray.get_collider() != null and aim_ray.get_collider().is_in_group("enemy"):
				aim_ray.get_collider().hit()
		instance = bullet.instantiate() 
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		add_child(instance)

func _ads():
	if !gun_anim.is_playing():
		gun_anim.play("ads")
	is_ads = true
	
func _ads_down():
	if !gun_anim.is_playing():
		gun_anim.play_backwards("ads")
	is_ads = false

func _reload():
	if!gun_anim.is_playing():
		gun_anim.play("reload")
