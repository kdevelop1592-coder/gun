extends Node3D

@export var tracer_scene: PackedScene
@export var recoil_kick: float = 0.07
@export var recoil_return_speed: float = 12.0
@export var sway_amount: float = 0.0018
@export var sway_max_offset: float = 0.04
@export var sway_max_rot_deg: float = 6.0
@export var sway_lerp_speed: float = 10.0

var current_recoil: float = 0.0
var initial_position: Vector3
var initial_rotation: Vector3
var sway_offset: Vector2 = Vector2.ZERO

@onready var muzzle_flash: MeshInstance3D = $MuzzleFlash
@onready var muzzle_point: Marker3D = $MuzzlePoint
@onready var muzzle_debug: MeshInstance3D = $MuzzlePoint/MuzzleDebug

func _ready() -> void:
	initial_position = position
	initial_rotation = rotation
	muzzle_flash.visible = false

func _process(delta: float) -> void:
	current_recoil = move_toward(current_recoil, 0.0, recoil_return_speed * delta)
	sway_offset = sway_offset.lerp(Vector2.ZERO, sway_lerp_speed * delta)
	var x_off: float = clamp(sway_offset.x, -sway_max_offset, sway_max_offset)
	var y_off: float = clamp(sway_offset.y, -sway_max_offset, sway_max_offset)
	position = initial_position + Vector3(x_off, y_off, current_recoil)
	var max_rot: float = deg_to_rad(sway_max_rot_deg)
	rotation.x = initial_rotation.x + clamp(-y_off * 3.0, -max_rot, max_rot)
	rotation.y = initial_rotation.y + clamp(-x_off * 2.2, -max_rot, max_rot)

func play_fire_feedback() -> void:
	current_recoil = -recoil_kick
	muzzle_flash.visible = true
	await get_tree().create_timer(0.04).timeout
	muzzle_flash.visible = false

func add_sway(mouse_delta: Vector2) -> void:
	sway_offset.x = clamp(sway_offset.x - mouse_delta.x * sway_amount, -sway_max_offset, sway_max_offset)
	sway_offset.y = clamp(sway_offset.y + mouse_delta.y * sway_amount, -sway_max_offset, sway_max_offset)

func spawn_tracer(target_pos: Vector3) -> void:
	if tracer_scene == null:
		return
	var tracer: Node = tracer_scene.instantiate()
	if tracer == null:
		return
	get_tree().current_scene.add_child(tracer)
	if tracer.has_method("setup"):
		tracer.setup(muzzle_point.global_position, target_pos)

func toggle_muzzle_debug() -> void:
	if muzzle_debug == null:
		return
	muzzle_debug.visible = not muzzle_debug.visible
	print("MuzzlePoint local position: ", muzzle_point.position)
