extends Control
signal navigate(next: PackedScene)

@export var next_screen: PackedScene
@onready var evidence_list: VBoxContainer = $CenterContainer/EvidenceList

func _on_continue_pressed() -> void:
	navigate.emit(next_screen)

func _ready() -> void:
	for child in evidence_list.get_children():
		if child is not Button:
			continue

		var btn: Button = child
		var id := btn.name

		# Make button text match evidence title (nice polish, zero effort)
		var ev := EvidenceDb.get_evidence(id)
		if not ev.is_empty():
			btn.text = str(ev.get("title", id))

		btn.pressed.connect(func(): _on_evidence_clicked(id))

func _on_evidence_clicked(evidence_id: String) -> void:
	var ev := EvidenceDb.get_evidence(evidence_id)
	if ev.is_empty():
		push_warning("Intake: unknown evidence id: " + evidence_id)
		return

	AppState.pin_evidence(ev)
	get_tree().call_group("evidence_board", "spawn_paper", evidence_id)
