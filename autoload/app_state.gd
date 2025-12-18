extends Node
class_name AppState

var pinned_evidence: Array[Dictionary] = []
var edges: Array[Dictionary] = []
var _edge_index: Dictionary = {} # key -> truee

func _edge_key(a_id: String, b_id: String, edge_type: String) -> String:
	# UNDIRECTED uniqueness: A-B equals B-A
	var a := a_id
	var b := b_id
	if a > b:
		var tmp := a
		a = b
		b = tmp
	return "%s|%s|%s" % [a, b, edge_type]

func pin_evidence(e: Dictionary) -> void:
	if pinned_evidence.any(func(x): return x.get("id") == e.get("id")):
		return
	pinned_evidence.append(e)

func add_edge(a_id: String, b_id: String, edge_type: String) -> bool:
	var key := _edge_key(a_id, b_id, edge_type)
	if _edge_index.has(key):
		return false # already exists
	_edge_index[key] = true
	edges.append({"a": a_id, "b": b_id, "type": edge_type})
	return true

func reset_day() -> void:
	pinned_evidence.clear()
	edges.clear()
