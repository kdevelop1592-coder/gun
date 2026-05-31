extends Node3D

@export var speed: float = 120.0

var target_position: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var travel_left: float = 0.0

func setup(start_pos: Vector3, end_pos: Vector3) -> void:
	global_position = start_pos
	target_position = end_pos
	var to_target: Vector3 = target_position - start_pos
	travel_left = to_target.length()
	direction = to_target.normalized()

func _process(delta: float) -> void:
	if travel_left <= 0.0:
		queue_free()
		return
	var step: float = speed * delta
	var move_dist: float = min(step, travel_left)
	global_position += direction * move_dist
	travel_left -= move_dist
	if travel_left <= 0.0:
		queue_free()

