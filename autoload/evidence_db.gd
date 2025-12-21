# res://autoload/evidence_db.gd
extends Node

var evidence_by_id: Dictionary = {}
var current_case_id: String = "case_001"

func load_case(case_id: String) -> void:
	current_case_id = case_id
	var path := "res://data/cases/%s/evidence.json" % case_id

	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("EvidenceDb.load_case: could not open " + path)
		return

	var text := f.get_as_text()

	# JSON.parse_string returns Variant (Array/Dictionary/null). Be explicit to avoid Variant inference warnings.
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("EvidenceDb.load_case: invalid JSON in " + path)
		return

	if parsed is not Array:
		push_error("EvidenceDb.load_case: evidence.json must be a JSON array")
		return

	var parsed_array: Array = parsed

	evidence_by_id.clear()

	for item: Variant in parsed_array:
		if item is not Dictionary:
			continue
		var item_dict: Dictionary = item

		var id := str(item_dict.get("id", ""))
		if id == "":
			continue

		evidence_by_id[id] = item_dict

	print("EvidenceDb: loaded ", evidence_by_id.size(), " items from ", path)

func get_evidence(evidence_id: String) -> Dictionary:
	var v: Variant = evidence_by_id.get(evidence_id)
	return v if v is Dictionary else {}
