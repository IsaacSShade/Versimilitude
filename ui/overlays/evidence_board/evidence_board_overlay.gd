extends CanvasLayer

@onready var board_root: Control = $BoardRoot
@onready var cards_layer: Control = $BoardRoot/BoardBackground/CardsLayer
@onready var edges_layer: Node2D = $BoardRoot/BoardBackground/EdgesLayer

@export var slide_duration := 0.22

@export var paper_card_scene: PackedScene
@export var edge_line_scene: PackedScene

var _cards: Array[Control] = []

var _is_open := false
var _tween: Tween

var _open_y := 0.0
var _closed_y := 0.0

var _pending_pin_card: Control = null
var _cards_by_inst: Dictionary = {}    # int -> Control
var _edges_by_key: Dictionary = {} # "lo|hi" -> EdgeLine node

func _ready() -> void:
	# So other screens can talk to this later using call_group("evidence_board", ...)
	add_to_group("evidence_board")
	call_deferred("_init_positions")

func _init_positions() -> void:
	# This is the "resting" position based on anchors/margins.
	_open_y = board_root.position.y

	# Fully hidden above the screen (bottom edge at y=0).
	_closed_y = -board_root.size.y

	_is_open = false
	board_root.position.y = _closed_y
	board_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_board"):
		toggle()
		# Mark input as handled so it doesn't leak into underlying UI.
		get_viewport().set_input_as_handled()

func _snap_to_closed() -> void:
	# Put it off-screen above the top.
	_is_open = false
	board_root.position.y = -board_root.size.y

func _animate_to_y(target_y: float) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(board_root, "position:y", target_y, slide_duration)

func _place_new_card(card: Control) -> void:
	if cards_layer.size.x <= 1.0 or cards_layer.size.y <= 1.0:
		await get_tree().process_frame

	var margin := 24.0
	var dx := 18.0
	var dy := 14.0
	var tol := 2.0 # pixels; how close counts as "in that stack slot"

	# your exact stacking vibe, but fill the first empty SLOT
	for n in range(0, 300):
		var x := margin + float(n) * dx
		var y := margin + float(n) * dy

		# clamp to board (same spirit as your original)
		x = clampf(x, margin, maxf(margin, cards_layer.size.x - card.size.x - margin))
		y = clampf(y, margin, maxf(margin, cards_layer.size.y - card.size.y - margin))

		var pos := Vector2(x, y)

		if not _stack_slot_occupied(pos, tol, card):
			card.position = pos
			return

	# fallback
	card.position = Vector2(margin, margin)

func _stack_slot_occupied(slot_pos: Vector2, tol: float, ignore_card: Control) -> bool:
	for child in cards_layer.get_children():
		if child == ignore_card or not (child is Control):
			continue
		var c := child as Control

		# Occupied means: a card's top-left is basically at this slot.
		if c.position.distance_to(slot_pos) <= tol:
			return true

	return false

func _on_card_pin_clicked(_evidence_id: String, card: Control) -> void:
	if _pending_pin_card == null:
		_pending_pin_card = card
		_set_card_selected(card, true)
		return

	if _pending_pin_card == card:
		_set_card_selected(card, false)
		_pending_pin_card = null
		return

	# Second card picked → connect attempt (we’ll draw/record edges next step)
	_set_card_selected(_pending_pin_card, false)
	var a_id: int = int(_pending_pin_card.get_instance_id())
	var b_id: int = int(card.get_instance_id())
	var ok := AppState.add_instance_edge(a_id, b_id, "DEFAULT")
	print("Edge added? %s (%d -> %d)" % [str(ok), a_id, b_id])
	if ok:
		var lo: int = a_id if a_id < b_id else b_id
		var hi: int = b_id if a_id < b_id else a_id
		var key: String = "%d|%d" % [lo, hi]

		if not _edges_by_key.has(key):
			if edge_line_scene == null:
				push_error("EvidenceBoardOverlay: edge_line_scene not assigned.")
				return

			var edge := edge_line_scene.instantiate()
			edges_layer.add_child(edge)
			_edges_by_key[key] = edge

			edge.call("init_edge", lo, hi)
	_pending_pin_card = null

func _set_card_selected(card: Control, selected: bool) -> void:
	if not is_instance_valid(card):
		return
	card.modulate = Color(1, 1, 0.85) if selected else Color(1, 1, 1)

func _process(_delta: float) -> void:
	for key_v in _edges_by_key.keys():
		var key: String = key_v as String
		var edge: Node = _edges_by_key.get(key) as Node
		if edge == null or not is_instance_valid(edge):
			_edges_by_key.erase(key)
			continue

		var parts: PackedStringArray = key.split("|")
		if parts.size() != 2:
			continue

		var a_id: int = int(parts[0])
		var b_id: int = int(parts[1])

		var a_card: Control = _cards_by_inst.get(a_id) as Control
		var b_card: Control = _cards_by_inst.get(b_id) as Control
		if a_card == null or b_card == null:
			continue

		var a_pin_global: Vector2 = _get_pin_global(a_card)
		var b_pin_global: Vector2 = _get_pin_global(b_card)

		var a_local: Vector2 = edges_layer.to_local(a_pin_global)
		var b_local: Vector2 = edges_layer.to_local(b_pin_global)

		edge.call("set_endpoints_local", a_local, b_local)

func _get_pin_global(card: Control) -> Vector2:
	var pin := card.get_node_or_null("PinButton") as Control
	if pin != null:
		var r: Rect2 = pin.get_global_rect()
		return r.position + (r.size * 0.5)

	# fallback: top-center of card
	var cr: Rect2 = card.get_global_rect()
	return Vector2(cr.position.x + cr.size.x * 0.5, cr.position.y)
	
func toggle() -> void:
	if _is_open:
		close()
	else:
		open()

func open() -> void:
	_is_open = true
	board_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_animate_to_y(_open_y)

func close() -> void:
	_is_open = false
	_animate_to_y(_closed_y)
	
	# Let clicks pass through once we're closed (one-shot after tween)
	if _tween and _tween.is_valid():
		_tween.finished.connect(func():
			if not _is_open:
				board_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		, CONNECT_ONE_SHOT)
	else:
		board_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func spawn_paper(evidence_id: String) -> void:
	var evidence := EvidenceDb.get_evidence(evidence_id)
	if evidence.is_empty():
		push_warning("spawn_paper: unknown evidence id: " + evidence_id)
		return

	# Safety: even if caller forgets, we keep state consistent.
	AppState.pin_evidence(evidence)

	if paper_card_scene == null:
		push_error("EvidenceBoardOverlay: paper_card_scene not assigned in Inspector.")
		return

	var card := paper_card_scene.instantiate()
	cards_layer.add_child(card)
	
	var inst_id: int = int(card.get_instance_id())
	_cards_by_inst[inst_id] = card
	card.tree_exited.connect(func():
		_cards_by_inst.erase(inst_id)
	)
	
	# Typed call without relying on casting:
	card.call("set_evidence", evidence)
	_cards.append(card)
	if card.has_signal("pin_clicked"):
		card.connect("pin_clicked", Callable(self, "_on_card_pin_clicked").bind(card))

	# Place it somewhere visible (simple for now; better scatter in Slice 4)
	call_deferred("_place_new_card", card)
