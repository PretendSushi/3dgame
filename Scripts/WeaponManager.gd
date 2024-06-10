extends Node3D

signal item_in_pickup_range(item)
signal item_not_in_pickup_range(item)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pickup_detection_body_entered(body):
	print(body)
	if "weapon_name" in body:
		item_in_pickup_range.emit(body.item_id)
	else:
		item_in_pickup_range.emit(body)
	


func _on_pickup_detection_body_exited(body):
	if "weapon_name" in body:
		item_not_in_pickup_range.emit(body.item_id)
