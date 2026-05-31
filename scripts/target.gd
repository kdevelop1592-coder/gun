extends StaticBody3D

@export var move_amplitude: float = 1.5
@export var move_speed: float = 2.0
@export var respawn_delay_sec: float = 1.2

var base_position: Vector3
var t: float = 0.0
var alive: bool = true
var respawn_left: float = 0.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var hit_particles: GPUParticles3D = $HitParticles

func _ready() -> void:
	base_position = global_position
	reset_target()

func _process(delta: float) -> void:
	if not alive:
		respawn_left -= delta
		if respawn_left <= 0.0:
			reset_target()
		return
	t += delta
	global_position = base_position + Vector3(sin(t * move_speed) * move_amplitude, 0.0, 0.0)

func hit() -> void:
	if not alive:
		return
	alive = false
	respawn_left = respawn_delay_sec
	hit_particles.restart()
	hit_particles.emitting = true
	mesh.visible = false
	collision.disabled = true

func reset_target() -> void:
	alive = true
	respawn_left = 0.0
	hit_particles.emitting = false
	mesh.visible = true
	collision.disabled = false
	base_position = global_position
	t = randf() * TAU
