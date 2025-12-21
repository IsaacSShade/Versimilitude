extends Panel

# TODO: Add art or assets to create a cursor that looks like a grabby hand
signal pin_clicked(evidence_id: String)

@onready var pin_button: BaseButton = get_node_or_null("PinButton")
@onready var title_label: Label = get_node_or_null("Padding/Content/Title")
@onready var body_label: RichTextLabel = get_node_or_null("Padding/Content/Body")

var _evidence: Dictionary = {}

var _dragging := false
var _drag_offset := Vector2.ZERO
var evidence_id: String = ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_DRAG
	_set_drag_mouse_passthrough()
	_apply_evidence()
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

func set_evidence(e: Dictionary) -> void:
	_evidence = e
	if is_inside_tree():
		_apply_evidence()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
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
		var min_x: float = pr.position.x
		var min_y: float = pr.position.y
		var max_x: float = pr.position.x + pr.size.x - s.x
		var max_y: float = pr.position.y + pr.size.y - s.y

		new_global.x = clampf(new_global.x, min_x, max_x)
		new_global.y = clampf(new_global.y, min_y, max_y)

		global_position = new_global
		accept_event()

func _apply_evidence() -> void:
	if _evidence.is_empty():
		return
	if title_label == null:
		push_error("PaperCard: Missing Padding/Content/Title")
		return

	var evidence_id := str(_evidence.get("id", ""))
	title_label.text = str(_evidence.get("title", evidence_id))

	if body_label != null:
		body_label.text = str(_evidence.get("body", ""))
