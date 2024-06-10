extends Control

@onready var healthbar = $TopBars/Healthbar
@onready var staminabar = $TopBars/Staminabar
@onready var ammocount = $BottomBars/HBoxContainer/AmmoCount
@onready var reservecount = $BottomBars/HBoxContainer/ReserveCount
@onready var sanitybar = $HBoxContainer/Sanitybar
@onready var xpbar = $TopBars/XPBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_health_changed(health):
#	healthbar.value = health
	var healthbar_tween = get_tree().create_tween()
	healthbar_tween.tween_property(healthbar, "value", health, 0.2)



func _on_player_stamina_changed(stamina):
	var stamina_tween = get_tree().create_tween()
	stamina_tween.tween_property(staminabar, "value", stamina, 0.2)

func _on_player_ammo_changed(ammo):
	ammocount.text = str(ammo)

func _on_player_reserve_changed():
	reservecount.text = str(int(reservecount.text) - 1)
	ammocount.text = str(30)


func _on_player_sanity_changed(sanity):
	var sanitybar_tween = get_tree().create_tween()
	sanitybar_tween.tween_property(sanitybar, "value", sanity, 0.2)


func _on_player_xp_changed(xp):
	xpbar.visible = true
	var xpbar_tween = get_tree().create_tween()
	xpbar_tween.tween_property(xpbar, "value", xp, 0.2)
	await get_tree().create_timer(2).timeout
	xpbar.visible = false
#	var start_color = Color(1.0,1.0,1.0,1.0)
#	var end_color = Color(1.0,1.0,1.0,0.0)
#	xpbar_tween.interpolate_property(self, "modulate", start_color,end_color,1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)


func _on_player_initialize_bars(max_health, health, max_stamina, stamina, sanity, xp):
	_ready()
	healthbar.max_value = max_health
	healthbar.value = health
	staminabar.max_value = max_stamina
	staminabar.value = stamina
	sanitybar.value = sanity
	xpbar.value = xp
