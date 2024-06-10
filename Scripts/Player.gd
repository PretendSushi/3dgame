extends CharacterBody3D

#player info
var player_name : String
var sex
var race
var level
var xp

#attributes
var strength
var reflexes
var charisma
var constitution
var intelligence
var perception

#vital variables
var max_health
var health
var max_stamina
var stamina
var stamina_gen_timeout = false
var sanity

#vital constants
const BASE_HEALTH = 30
const BASE_STAMINA = 30
const HP_INC_PER_ATT_POINT = 5
const STAM_INC_PER_ATT_POINT = 20
const REF_INC_PER_ATT_POINT = 0.5

#movement variables
var speed
var sprint_speed
const BASE_SPRINT_SPEED = 6.0
const WALK_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.001
const HIT_STAGGER = 8.0

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

signal player_hit
signal interact_attempt(item)
signal health_changed(health)
signal stamina_changed(stamina)
signal ammo_changed(ammo)
signal reserve_changed()
signal sanity_changed(sanity)
signal xp_changed(xp)
signal initialize_bars(max_health, health, max_stamina, stamina, sanity, xp)
signal initialize_char_sheet(attr_arr)
signal player_death()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

var bullet = load("res://Scenes/bullet.tscn")
var instance

var is_inv_open = false
var is_ads = false
var is_dialogue_open = false

var item_in_pickup_range = null

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var pick_up_gun = $"../../Weapons/SCAR-L_Remake"
@onready var weapon_manager = $Head/Camera3D/WeaponManager

@onready var aim_ray = $Head/Camera3D/AimRay

var weapon_class = preload("res://Scenes/Weapons.tscn")
var curr_weapon = Node3D.new()
var curr_mag_count
var weapon_slot1
var weapon_slot2
var curr_slot


func _ready():
	#almost everything in this method is for testing, should be replaced with robust initialization code
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var weapon_class_parent = weapon_class.instantiate()
	curr_weapon = weapon_class_parent.get_child(1)
	weapon_class_parent.remove_child(weapon_class_parent.get_child(1))
	weapon_manager.add_child(curr_weapon)
	
	strength = 9
	reflexes = 15
	charisma = 10
	constitution = 1
	intelligence = 10
	perception = 13
	
	_set_max_health()
	_set_max_stamina()
	_set_sprint_speed()
	
	health = max_health
	stamina = max_stamina
	
	curr_mag_count = 30
	weapon_slot1 = curr_weapon
	curr_slot = weapon_slot1
	sanity = 100
	xp = 1409
	emit_signal("initialize_bars", max_health, health,max_stamina, stamina, sanity, xp)
	emit_signal("initialize_char_sheet",[strength,reflexes,charisma,constitution,intelligence,perception])
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if !is_inv_open && !is_dialogue_open:
			head.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		

func _physics_process(delta):
	# Add the gravity.
	if health <= 0:
		emit_signal("player_death")
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("sprint"):
		_sprint()
		
	else:
		speed = WALK_SPEED
	
	if stamina < max_stamina:
		stamina += 0.1
		emit_signal("stamina_changed", stamina)
			
	if Input.is_action_just_pressed("inventory"):
		_open_close_inv()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if !is_inv_open:
		_walk(delta)
	
	#head bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	#FOV
	var velocity_clamped =  clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = BASE_FOV + FOV_CHANGE *velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	if curr_weapon != null:
		if(curr_weapon.fire_rate == curr_weapon.FireRate.AUTO):
			if (Input.is_action_pressed("left_click")):
				_shoot()
		else:
			if (Input.is_action_just_pressed("left_click")):
				_shoot()
	
		if (Input.is_action_just_pressed("right_click")):
			if(!is_inv_open):
				curr_weapon._ads()
				
					
		if (Input.is_action_just_released("right_click")):
			if(!is_inv_open):
				curr_weapon._ads_down()
				
		
		if Input.is_action_just_pressed("reload"):
			if(!is_inv_open):
				curr_weapon._reload()
				curr_mag_count = 30
				emit_signal("reserve_changed")

	if (Input.is_action_just_pressed("interact")):
		if(item_in_pickup_range):
			interact_attempt.emit(item_in_pickup_range)
	
	if (Input.is_action_just_pressed("one")):
		if weapon_slot1 != null:
			_assign_weapon(weapon_slot1)
		
	if (Input.is_action_just_pressed("two")):
		if weapon_slot2 != null:
			_assign_weapon(weapon_slot2)
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func _sprint():
	if stamina > 0:
		speed = sprint_speed
		stamina -= 1
		emit_signal("stamina_changed", stamina)
	else:
		speed = WALK_SPEED
		
func _open_close_inv():
	if is_inv_open == false:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		velocity.x = 0
		velocity.z = 0
	elif is_inv_open == true:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		velocity.x = 0
		velocity.z = 0
		
	is_inv_open = !is_inv_open

func _walk(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

func _shoot():
	if(!is_inv_open):
		if curr_mag_count > 0:
			curr_weapon._shoot(aim_ray)
			curr_mag_count -= 1
			emit_signal("ammo_changed", curr_mag_count)

func hit(dir, damage):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER
	health -= damage
	emit_signal("health_changed", health)


func _on_weapon_manager_item_in_pickup_range(item):
	item_in_pickup_range = item


func _on_weapon_manager_item_not_in_pickup_range(item):
	item_in_pickup_range = null


func _on_inventory_weapon_changed(weapon_id, slot):
	var new_weapon = _find_weapon(weapon_id)
	if (slot == "slot1" and curr_slot == weapon_slot1) or (slot == "slot2" and curr_slot == weapon_slot2):
		weapon_manager.remove_child(curr_weapon)
		curr_weapon = new_weapon
		weapon_manager.add_child(curr_weapon)
	match slot:
		"slot1":
			weapon_slot1 = new_weapon
		"slot2":
			weapon_slot2 = new_weapon

func _assign_weapon(slot):
	weapon_manager.remove_child(curr_weapon)
	match slot:
		weapon_slot1:
			curr_weapon = weapon_slot1
		weapon_slot2:
			curr_weapon = weapon_slot2
	weapon_manager.add_child(curr_weapon)


func _on_inventory_clean_slots(slots):
	for i in range(slots.size()):
		var new_weapon = _find_weapon(slots[i]) 
		match i:
			0:
				weapon_slot1 = new_weapon
			1:
				weapon_slot2 = new_weapon


func _find_weapon(weapon_id):
	var weapon = DataHandler._get_weapon_by_id(weapon_id) #gets JSON object of weapon
	var weapon_class_parent = weapon_class.instantiate() #instantiate the weapon class to find the right weapon
	var weapons = weapon_class_parent.get_children() #get all the weapons in the weapon class
	if weapon != null:
		for i in range(weapons.size()):
			#loop through all the weapons, match on the name of the node and the name in the JSON object
			if weapons[i].get_name() == weapon["Name"]:
				#new_weapon temporarily holds the weapon object. None of its fields are populated
				var new_weapon = weapon_class_parent.get_child(i)
				#must remove the weapon we found from the weapon class we instantiated, in order to add it as a child to the weapon manager
				weapon_class_parent.remove_child(weapon_class_parent.get_child(i))
				#we can now assign the weapon a fire rate, based on the JSON object. curr_weapon is just there to get the FireRate enum
				match weapon["FireRate"]:
					"AUTO":
						new_weapon.fire_rate = curr_weapon.FireRate.AUTO
					"SEMI":
						new_weapon.fire_rate = curr_weapon.FireRate.SEMI
				#we can return from here, once the weapon is found there's no need to keep looping
				return new_weapon
	#if we made it this far without returning, the weapon isn't in the weapon class
	return null

func _on_generic_soldier_enemy_killed():
	sanity -= 10
	emit_signal("sanity_changed", sanity)
	xp += 30
	emit_signal("xp_changed", xp)

func _set_max_health():
	max_health = BASE_HEALTH + (HP_INC_PER_ATT_POINT * constitution)
	
func _set_max_stamina():
	max_stamina = BASE_STAMINA + (STAM_INC_PER_ATT_POINT * constitution)
	
func _set_sprint_speed():
	sprint_speed = BASE_SPRINT_SPEED + (REF_INC_PER_ATT_POINT * reflexes)


func _on_character_sheet_point_add(attr):
	match attr:
		"Strength":
			strength += 1
		"Reflexes":
			reflexes += 1
		"Charisma":
			charisma += 1
		"Constitution":
			constitution += 1
		"Intelligence":
			intelligence += 1
		"Perception":
			perception += 1
	_set_max_health()
	_set_max_stamina()
	_set_sprint_speed()
	emit_signal("initialize_bars", max_health, health, max_stamina, stamina, sanity, xp)


func _on_character_sheet_point_sub(attr):
	match attr:
		"Strength":
			strength -= 1
		"Reflexes":
			reflexes -= 1
		"Charisma":
			charisma -= 1
		"Constitution":
			constitution -= 1
		"Intelligence":
			intelligence -= 1
		"Perception":
			perception -= 1
	_set_max_health()
	_set_max_stamina()
	_set_sprint_speed()
	emit_signal("initialize_bars", max_health, health, max_stamina, stamina, sanity, xp)


func _on_level_lock_dialogue():
	is_dialogue_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
