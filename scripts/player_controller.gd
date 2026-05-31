extends CharacterBody3D

@export var mouse_sensitivity: float = 0.002
@export var pitch_min_deg: float = -75.0
@export var pitch_max_deg: float = 75.0
@export var shot_cooldown_sec: float = 0.12
@export var magazine_size: int = 30
@export var reload_time_sec: float = 1.6

var pitch: float = 0.0
var can_shoot: bool = true
var is_reloading: bool = false
var ammo_in_mag: int = 0

@onready var camera: Camera3D = $Camera3D
@onready var gun: Node3D = get_node_or_null("Camera3D/Gun")
@onready var cooldown_timer: Timer = $ShotCooldownTimer
@onready var reload_timer: Timer = $ReloadTimer
@onready var game_manager: Node = get_tree().get_first_node_in_group("game_manager")

func _ready() -> void:
	if game_manager == null:
		game_manager = get_parent()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cooldown_timer.wait_time = shot_cooldown_sec
	reload_timer.wait_time = reload_time_sec
	ammo_in_mag = magazine_size

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
		camera.rotation.x = pitch
		if gun != null and gun.has_method("add_sway"):
			gun.add_sway(event.relative)
	if event.is_action_pressed("toggle_muzzle_debug"):
		if gun != null and gun.has_method("toggle_muzzle_debug"):
			gun.toggle_muzzle_debug()
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		_try_shoot()

func _try_shoot() -> void:
	if is_reloading:
		return
	if not can_shoot:
		return
	if game_manager != null and not game_manager.is_running:
		return
	if ammo_in_mag <= 0:
		_start_reload()
		return
	can_shoot = false
	cooldown_timer.start()
	ammo_in_mag -= 1
	var shot_result: Dictionary = _perform_hitscan()
	var did_hit: bool = bool(shot_result["did_hit"])
	var impact_point: Vector3 = shot_result["impact_point"] as Vector3
	if gun != null and gun.has_method("play_fire_feedback"):
		gun.play_fire_feedback()
	if gun != null and gun.has_method("spawn_tracer"):
		gun.spawn_tracer(impact_point)
	if game_manager != null:
		game_manager.register_shot(did_hit)
	if ammo_in_mag <= 0:
		_start_reload()

func _perform_hitscan() -> Dictionary:
	var origin: Vector3 = camera.global_position
	var end: Vector3 = origin + (-camera.global_basis.z * 250.0)
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return {"did_hit": false, "impact_point": end}
	var collider: Object = result["collider"]
	var impact: Vector3 = result["position"]
	if collider != null and collider.has_method("hit"):
		collider.hit()
		return {"did_hit": true, "impact_point": impact}
	return {"did_hit": false, "impact_point": impact}

func _on_shot_cooldown_timer_timeout() -> void:
	can_shoot = true

func _on_reload_timer_timeout() -> void:
	ammo_in_mag = magazine_size
	is_reloading = false
	if game_manager != null and game_manager.has_method("set_reload_message_visible"):
		game_manager.set_reload_message_visible(false)

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _start_reload() -> void:
	if is_reloading:
		return
	is_reloading = true
	reload_timer.start()
	if game_manager != null and game_manager.has_method("set_reload_message_visible"):
		game_manager.set_reload_message_visible(true)
