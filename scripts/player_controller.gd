extends CharacterBody3D

@export var mouse_sensitivity: float = 0.002
@export var pitch_min_deg: float = -75.0
@export var pitch_max_deg: float = 75.0
@export var shot_cooldown_sec: float = 0.12

var pitch: float = 0.0
var can_shoot: bool = true

@onready var camera: Camera3D = $Camera3D
@onready var gun: Node3D = get_node_or_null("Camera3D/Gun")
@onready var cooldown_timer: Timer = $ShotCooldownTimer
@onready var game_manager: Node3D = get_tree().get_first_node_in_group("game_manager")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cooldown_timer.wait_time = shot_cooldown_sec

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
		camera.rotation.x = pitch
		if gun != null and gun.has_method("add_sway"):
			gun.add_sway(event.relative)
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		_try_shoot()

func _try_shoot() -> void:
	if not can_shoot:
		return
	if game_manager != null and not game_manager.is_running:
		return
	can_shoot = false
	cooldown_timer.start()
	var did_hit := _perform_hitscan()
	if gun != null and gun.has_method("play_fire_feedback"):
		gun.play_fire_feedback()
	if game_manager != null:
		game_manager.register_shot(did_hit)

func _perform_hitscan() -> bool:
	var origin: Vector3 = camera.global_position
	var end: Vector3 = origin + (-camera.global_basis.z * 250.0)
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return false
	var collider: Object = result["collider"]
	if collider != null and collider.has_method("hit"):
		collider.hit()
		return true
	return false

func _on_shot_cooldown_timer_timeout() -> void:
	can_shoot = true

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
