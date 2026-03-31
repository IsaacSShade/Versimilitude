extends Control
signal navigate(next: PackedScene)

@export var next_screen: PackedScene
@export var ink_file: String = "res://data/cases/case_001/dialogue/interview_bob.ink"
@export var characters_file: String = "res://data/cases/case_001/dialogue/characters.json"
@export var interviewee_id: String = "bob"

@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var interviewee_sprite: TextureRect = $VBoxContainer/CharacterArea/CastRow/IntervieweeVBox/IntervieweeSprite
@onready var interviewee_name: Label = $VBoxContainer/CharacterArea/CastRow/IntervieweeVBox/IntervieweeName
@onready var side_character_box: VBoxContainer = $VBoxContainer/CharacterArea/CastRow/SideCharacterVBox
@onready var side_character_sprite: TextureRect = $VBoxContainer/CharacterArea/CastRow/SideCharacterVBox/SideCharacterSprite
@onready var side_character_name: Label = $VBoxContainer/CharacterArea/CastRow/SideCharacterVBox/SideCharacterName
@onready var dialogue_box: PanelContainer = $VBoxContainer/DialogueBox
@onready var speaker_label: Label = $VBoxContainer/DialogueBox/MarginContainer/DialogueVBox/SpeakerLabel
@onready var dialogue_text: RichTextLabel = $VBoxContainer/DialogueBox/MarginContainer/DialogueVBox/DialogueText
@onready var choices_container: VBoxContainer = $VBoxContainer/ChoicesContainer
@onready var advance_button: Button = $VBoxContainer/BottomBar/AdvanceButton

var _story := InkStoryRunner.new()
var _characters: Dictionary = {}
var _current_line_entry: Dictionary = {}
var _has_pinned_current_line := false
var _story_finished := false

func _ready() -> void:
	advance_button.pressed.connect(_on_advance_pressed)
	dialogue_box.gui_input.connect(_on_dialogue_box_input)

	if ink_file == "":
		push_error("InterviewScreen: ink_file export is not set.")
		return

	_characters = _load_json_dictionary(characters_file)
	_apply_interviewee_stage()
	_clear_side_character()

	if not _story.load_story(ink_file):
		return

	_advance_story()

func _load_json_dictionary(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("InterviewScreen: cannot open '%s'." % path)
		return {}

	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed == null or parsed is not Dictionary:
		push_error("InterviewScreen: invalid JSON in '%s'." % path)
		return {}

	return parsed as Dictionary

func _advance_story() -> void:
	_render_step(_story.continue_story())

func _render_step(step: Dictionary) -> void:
	match str(step.get("type", "")):
		"line":
			_story_finished = false
			_show_line(step)
		"choice":
			_story_finished = false
			_show_choices(step.get("choices", []))
		"end":
			_story_finished = true
			choices_container.visible = false
			advance_button.visible = true
			advance_button.text = "Finish"
		_:
			push_error("InterviewScreen: unsupported step type '%s'." % str(step.get("type", "")))

func _show_line(line_data: Dictionary) -> void:
	var speaker_id := str(line_data.get("speaker", ""))
	var tags: Dictionary = line_data.get("tags", {}) as Dictionary

	_update_stage_for_speaker(speaker_id)
	speaker_label.text = _get_display_name(speaker_id)
	dialogue_text.text = str(line_data.get("text", ""))
	_current_line_entry = _build_line_entry(line_data)
	_has_pinned_current_line = AppState.is_entry_pinned(str(_current_line_entry.get("id", "")))
	_update_dialogue_box_state()

	choices_container.visible = false
	advance_button.visible = true
	advance_button.text = "Next ->"

	_play_line_audio(str(tags.get("audio", "")))

func _show_choices(choices: Array) -> void:
	_build_choices(choices)
	choices_container.visible = true
	advance_button.visible = false

func _build_choices(choices: Array) -> void:
	for child in choices_container.get_children():
		child.queue_free()

	for i in range(choices.size()):
		var choice := choices[i] as Dictionary
		var btn := Button.new()
		btn.text = str(choice.get("text", ""))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_choice_pressed.bind(i))
		choices_container.add_child(btn)

func _apply_interviewee_stage() -> void:
	var character := _get_character(interviewee_id)
	interviewee_name.text = str(character.get("name", interviewee_id))

	var sprite_path := str(character.get("sprite", ""))
	interviewee_sprite.texture = load(sprite_path) as Texture2D if sprite_path != "" else null

func _update_stage_for_speaker(speaker_id: String) -> void:
	_apply_interviewee_stage()

	if speaker_id == "" or speaker_id == interviewee_id or speaker_id == "detective":
		_clear_side_character()
		return

	_show_side_character(speaker_id)

func _show_side_character(character_id: String) -> void:
	var character := _get_character(character_id)
	side_character_name.text = str(character.get("name", character_id))

	var sprite_path := str(character.get("sprite", ""))
	side_character_sprite.texture = load(sprite_path) as Texture2D if sprite_path != "" else null
	side_character_box.visible = true

func _clear_side_character() -> void:
	side_character_box.visible = false
	side_character_name.text = ""
	side_character_sprite.texture = null

func _get_character(character_id: String) -> Dictionary:
	return _characters.get(character_id, {}) as Dictionary

func _on_advance_pressed() -> void:
	if _story_finished:
		navigate.emit(next_screen)
		return

	_advance_story()

func _on_dialogue_box_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_pin_current_line()
		accept_event()

func _on_choice_pressed(choice_index: int) -> void:
	_render_step(_story.choose(choice_index))

func _pin_current_line() -> void:
	if _current_line_entry.is_empty() or _has_pinned_current_line:
		return

	AppState.pin_board_entry(_current_line_entry)
	get_tree().call_group("evidence_board", "spawn_entry", _current_line_entry)
	_has_pinned_current_line = true
	_update_dialogue_box_state()

func _build_line_entry(line_data: Dictionary) -> Dictionary:
	var speaker_id := str(line_data.get("speaker", ""))
	var speaker_name := _get_display_name(speaker_id)
	var text := str(line_data.get("text", ""))
	var tags: Dictionary = line_data.get("tags", {}) as Dictionary
	var linked_evidence_id := str(tags.get("evidence", ""))
	var title := "%s said" % speaker_name if speaker_name != "" else "Interview note"
	var body := text

	return {
		"id": "dialogue:%s:%s" % [_story.title, str(line_data.get("id", ""))],
		"kind": "dialogue",
		"title": title,
		"body": body,
		"source": "INTERVIEW",
		"speaker": speaker_name,
		"linked_evidence_id": linked_evidence_id
	}

func _get_display_name(speaker_id: String) -> String:
	var character := _get_character(speaker_id)
	return str(character.get("name", speaker_id))

func _update_dialogue_box_state() -> void:
	if _current_line_entry.is_empty():
		dialogue_box.self_modulate = Color(1, 1, 1)
		return

	dialogue_box.self_modulate = Color(0.82, 0.94, 0.82) if _has_pinned_current_line else Color(1, 1, 1)

func _play_line_audio(audio_path: String) -> void:
	if audio_path == "" or audio_path == "null":
		return

	var stream := load(audio_path) as AudioStream
	if stream == null:
		push_warning("InterviewScreen: could not load audio '%s'." % audio_path)
		return

	voice_player.stream = stream
	voice_player.play()
