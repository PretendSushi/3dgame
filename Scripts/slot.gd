extends TextureRect


signal slot_entered(slot)
signal slot_exited(slot)

@onready var filter = $StatusFilter

var slot_ID
var is_hovering := false
enum State {DEFAULT, TAKEN, FREE}
var state = State.DEFAULT
var item_stored = null


func _set_colour(a_state = State.DEFAULT) -> void:
	match a_state:
		State.DEFAULT:
			filter.color = Color(Color.WHITE, 0.0)
		State.TAKEN:
			filter.color = Color(Color.RED, 0.2)
		State.FREE:
			filter.color = Color(Color.GREEN, 0.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			emit_signal("slot_entered", self, self.get_parent())
	else:
		if is_hovering:
			is_hovering = false
			emit_signal("slot_exited",self)
