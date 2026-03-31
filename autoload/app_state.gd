extends Node

var pinned_entries: Array[Dictionary] = []
var instance_edges: Array[Dictionary] = []
var _instance_edge_index: Dictionary = {}

func _ready() -> void:
	# Optional: you can choose case per "day" here.
	start_day("case_001")

func start_day(case_id: String) -> void:
	reset_day()
	# EvidenceDb is a separate autoload singleton.
	EvidenceDb.load_case(case_id)

func _edge_key(a_id: String, b_id: String, edge_type: String) -> String:
	# UNDIRECTED uniqueness: A-B equals B-A
	var a := a_id
	var b := b_id
	if a > b:
		var tmp := a
		a = b
		b = tmp
	return "%s|%s|%s" % [a, b, edge_type]

func pin_board_entry(entry: Dictionary) -> void:
	var entry_id := str(entry.get("id", ""))
	if entry_id == "":
		return
	if is_entry_pinned(entry_id):
		return
	pinned_entries.append(entry.duplicate(true))

func is_entry_pinned(entry_id: String) -> bool:
	return pinned_entries.any(func(x): return x.get("id") == entry_id)

func pin_evidence(e: Dictionary) -> void:
	var evidence_entry := EvidenceDb.make_evidence_entry(e)
	if not evidence_entry.is_empty():
		pin_board_entry(evidence_entry)

func add_instance_edge(a_inst: int, b_inst: int, edge_type: String) -> bool:
	if a_inst == b_inst:
		return false

	var lo: int = a_inst if a_inst < b_inst else b_inst
	var hi: int = b_inst if a_inst < b_inst else a_inst
	var key := "%d|%d" % [lo, hi] # unique per pair (undirected)

	if _instance_edge_index.has(key):
		return false

	_instance_edge_index[key] = true
	instance_edges.append({
		"a": lo,
		"b": hi,
		"type": edge_type
	})
	return true

func reset_day() -> void:
	pinned_entries.clear()
	instance_edges.clear()
	_instance_edge_index.clear()
