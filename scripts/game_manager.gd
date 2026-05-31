extends Node3D

@export var round_time_sec: float = 60.0

var score: int = 0
var shots_fired: int = 0
var shots_hit: int = 0
var time_left: float = 0.0
var is_running: bool = false

@onready var ui_manager: Node = $UI
@onready var targets_root: Node3D = $Targets

func _ready() -> void:
	start_round()

func _process(delta: float) -> void:
	if not is_running:
		return
	time_left = max(time_left - delta, 0.0)
	ui_manager.update_time(time_left)
	if time_left <= 0.0:
		end_round()

func start_round() -> void:
	score = 0
	shots_fired = 0
	shots_hit = 0
	time_left = round_time_sec
	is_running = true
	ui_manager.update_score(score)
	ui_manager.update_accuracy(0.0)
	ui_manager.update_time(time_left)
	ui_manager.hide_end_panel()
	_reset_targets()

func end_round() -> void:
	is_running = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var accuracy := 0.0 if shots_fired == 0 else float(shots_hit) / float(shots_fired) * 100.0
	ui_manager.show_end_panel(score, accuracy)

func register_shot(did_hit: bool) -> void:
	if not is_running:
		return
	shots_fired += 1
	if did_hit:
		shots_hit += 1
		score += 10
	ui_manager.update_score(score)
	var accuracy := 0.0 if shots_fired == 0 else float(shots_hit) / float(shots_fired) * 100.0
	ui_manager.update_accuracy(accuracy)

func on_restart_requested() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	start_round()

func set_reload_message_visible(visible: bool) -> void:
	if ui_manager != null and ui_manager.has_method("set_reload_message_visible"):
		ui_manager.set_reload_message_visible(visible)

func _reset_targets() -> void:
	for child in targets_root.get_children():
		if child.has_method("reset_target"):
			child.reset_target()
