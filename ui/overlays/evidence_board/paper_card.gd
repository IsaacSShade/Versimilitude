extends Panel

# TODO: Add art or assets to create a cursor that looks like a grabby hand
signal pin_clicked(entry_id: String)

@onready var pin_button: BaseButton = get_node_or_null("PinButton")
@onready var title_label: Label = get_node_or_null("Padding/Content/Title")
@onready var body_label: RichTextLabel = get_node_or_null("Padding/Content/Body")

var _entry: Dictionary = {}
var _is_expanded := true
var _collapsed_size := Vector2(200, 96)
var _expanded_size := Vector2(240, 250)

var _dragging := false
var _drag_offset := Vector2.ZERO
var evidence_id: String = ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	_set_drag_mouse_passthrough()
	_apply_entry()
	if pin_button:
		pin_button.pressed.connect(func():
			pin_clicked.emit(evidence_id)
		)

func _set_drag_mouse_passthrough() -> void:
	# Make all descendants "click-through" so the Panel gets the drag input.
	# (If you later add a PinButton, exclude it here.)
	for c in find_children("*", "Control", true, false):
		if c == self:
			continue
		if c.name == "PinButton":
			continue
		(c as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_entry(entry: Dictionary) -> void:
	_entry = entry
	if is_inside_tree():
		_apply_entry()

func set_evidence(e: Dictionary) -> void:
	set_entry(EvidenceDb.make_evidence_entry(e))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and event.double_click:
			_toggle_expanded()
			accept_event()
			return

		if event.pressed:
			_dragging = true
			mouse_default_cursor_shape = Control.CURSOR_DRAG
			move_to_front()
			_drag_offset = get_global_mouse_position() - global_position
			accept_event()
		else:
			_dragging = false
			mouse_default_cursor_shape = Control.CURSOR_DRAG # Once I get a proper .png, adjust this
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		var parent := get_parent() as Control
		if parent == null:
			return

		var new_global: Vector2 = get_global_mouse_position() - _drag_offset

		var s: Vector2 = size
		if s == Vector2.ZERO:
			s = get_combined_minimum_size()

		var pr: Rect2 = parent.get_global_rect()
		var effective_scale := get_global_transform().get_scale()
		var min_x: float = pr.position.x
		var min_y: float = pr.position.y
		var max_x: float = pr.position.x + pr.size.x - s.x * effective_scale.x
		var max_y: float = pr.position.y + pr.size.y - s.y * effective_scale.y

		new_global.x = clampf(new_global.x, min_x, max_x)
		new_global.y = clampf(new_global.y, min_y, max_y)

		global_position = new_global.round()
		accept_event()

func _apply_entry() -> void:
	if _entry.is_empty():
		return
	if title_label == null:
		push_error("PaperCard: Missing Padding/Content/Title")
		return

	evidence_id = str(_entry.get("id", ""))
	title_label.text = str(_entry.get("title", evidence_id))

	if body_label != null:
		body_label.text = str(_entry.get("body", ""))

	_apply_fold_state()

func _toggle_expanded() -> void:
	_is_expanded = not _is_expanded
	_apply_fold_state()

func _apply_fold_state() -> void:
	if body_label == null:
		return

	custom_minimum_size = _expanded_size if _is_expanded else _collapsed_size
	size = custom_minimum_size
	body_label.visible = _is_expanded
