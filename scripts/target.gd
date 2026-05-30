extends StaticBody3D

@export var move_amplitude: float = 1.5
@export var move_speed: float = 2.0

var base_position: Vector3
var t: float = 0.0
var alive: bool = true

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	base_position = global_position
	reset_target()

func _process(delta: float) -> void:
	if not alive:
		return
	t += delta
	global_position = base_position + Vector3(sin(t * move_speed) * move_amplitude, 0.0, 0.0)

func hit() -> void:
	if not alive:
		return
	alive = false
	mesh.visible = false
	collision.disabled = true

func reset_target() -> void:
	alive = true
	mesh.visible = true
	collision.disabled = false
	base_position = global_position
	t = randf() * TAU

