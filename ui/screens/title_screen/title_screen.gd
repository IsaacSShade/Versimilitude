extends Control

signal navigate(next: PackedScene)

@export var next_screen: PackedScene

@onready var music: AudioStreamPlayer = $IntroMusic
@onready var fade: ColorRect = $Fade
@onready var start_btn: Button = $Center/VBox/Buttons/StartButton
@onready var beat_timer: Timer = $BeatCueTimer

var _starting := false

func _ready() -> void:
	# If you use this to gate EvidenceBoardOverlay toggling
	if Engine.has_singleton("AppState"):
		AppState.current_screen = "title"

	fade.color.a = 1.0
	start_btn.disabled = true
	get_tree().call_group("evidence_board", "set_toggle_enabled", false)

	music.play() # non-looping track

	# Fade in
	var t := create_tween()
	t.tween_property(fade, "color:a", 0.0, 2)
	await t.finished

	start_btn.disabled = false
	start_btn.grab_focus()

	# Optional: cue something at ~36s later (stub for now)
	if beat_timer:
		beat_timer.timeout.connect(_on_beat_cue)
		beat_timer.start()

func _on_StartButton_pressed() -> void:
	if _starting:
		return
	_starting = true
	start_btn.disabled = true

	# Fade out + kill audio
	var t := create_tween()
	t.parallel().tween_property(fade, "color:a", 1.0, 3)
	t.parallel().tween_property(music, "volume_db", -80.0, 3)
	await t.finished

	navigate.emit(next_screen)

func _on_beat_cue() -> void:
	# MVP stub: we’ll make something “AI watches you” happen here next step.
	# For now, do nothing (or print for verification).
	print("Beat cue hit (~36s)")
