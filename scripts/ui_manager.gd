extends CanvasLayer

@onready var score_label: Label = $HUD/ScoreLabel
@onready var acc_label: Label = $HUD/AccuracyLabel
@onready var time_label: Label = $HUD/TimeLabel
@onready var reload_label: Label = $HUD/ReloadLabel
@onready var end_panel: PanelContainer = $EndPanel
@onready var result_label: Label = $EndPanel/MarginContainer/VBoxContainer/ResultLabel
@onready var restart_btn: Button = $EndPanel/MarginContainer/VBoxContainer/RestartButton

var game_manager: Node3D

func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("game_manager")
	restart_btn.pressed.connect(_on_restart_button_pressed)
	set_reload_message_visible(false)
	hide_end_panel()

func update_score(score: int) -> void:
	score_label.text = "Score: %d" % score

func update_accuracy(acc: float) -> void:
	acc_label.text = "Accuracy: %.1f%%" % acc

func update_time(time_left: float) -> void:
	time_label.text = "Time: %d" % int(ceil(time_left))

func show_end_panel(score: int, acc: float) -> void:
	end_panel.visible = true
	result_label.text = "Round Over\nScore: %d\nAccuracy: %.1f%%" % [score, acc]

func hide_end_panel() -> void:
	end_panel.visible = false

func set_reload_message_visible(visible: bool) -> void:
	reload_label.visible = visible

func _on_restart_button_pressed() -> void:
	if game_manager != null:
		game_manager.on_restart_requested()
