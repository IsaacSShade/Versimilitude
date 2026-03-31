extends RefCounted
class_name InkStoryRunner

const STEP_LINE := "line"
const STEP_CHOICE := "choice"
const STEP_DIVERT := "divert"

var title: String = ""
var knots: Dictionary = {}
var current_knot: String = ""
var current_step_index := 0

func load_story(path: String) -> bool:
	knots.clear()
	title = ""
	current_knot = ""
	current_step_index = 0

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("InkStoryRunner: cannot open '%s'." % path)
		return false

	var lines := file.get_as_text().split("\n")
	var active_knot := ""
	var pending_choice: Dictionary = {}

	for raw_line in lines:
		var line := raw_line.strip_edges()
		if line == "" or line.begins_with("//"):
			continue

		if line.begins_with("===") and line.ends_with("==="):
			active_knot = line.trim_prefix("===").trim_suffix("===").strip_edges()
			if title == "":
				title = active_knot
			knots[active_knot] = []
			pending_choice.clear()
			continue

		if active_knot == "":
			continue

		if line.begins_with("* "):
			pending_choice = {
				"type": STEP_CHOICE,
				"text": _parse_choice_text(line),
				"target": ""
			}
			continue

		if line.begins_with("-> "):
			var target := line.trim_prefix("-> ").strip_edges()
			if not pending_choice.is_empty():
				var knot_steps: Array = knots.get(active_knot, [])
				if knot_steps.is_empty() or knot_steps[-1].get("type", "") != STEP_CHOICE:
					knot_steps.append({"type": STEP_CHOICE, "choices": []})
				pending_choice["target"] = target
				var choice_step: Dictionary = knot_steps[-1]
				var choices: Array = choice_step.get("choices", [])
				choices.append(pending_choice.duplicate(true))
				choice_step["choices"] = choices
				knot_steps[-1] = choice_step
				knots[active_knot] = knot_steps
				pending_choice.clear()
			else:
				var knot_steps: Array = knots.get(active_knot, [])
				knot_steps.append({
					"type": STEP_DIVERT,
					"target": target
				})
				knots[active_knot] = knot_steps
			continue

		var knot_steps: Array = knots.get(active_knot, [])
		knot_steps.append(_parse_dialogue_line(line, active_knot, knot_steps.size()))
		knots[active_knot] = knot_steps

	if title == "":
		return false

	current_knot = title
	return true

func continue_story() -> Dictionary:
	while true:
		var knot_steps: Array = knots.get(current_knot, [])
		if current_step_index >= knot_steps.size():
			return {"type": "end"}

		var step: Dictionary = knot_steps[current_step_index]
		current_step_index += 1

		match str(step.get("type", "")):
			STEP_LINE:
				return step
			STEP_CHOICE:
				return step
			STEP_DIVERT:
				var target := str(step.get("target", ""))
				if target == "END":
					return {"type": "end"}
				if not knots.has(target):
					push_error("InkStoryRunner: unknown knot '%s'." % target)
					return {"type": "end"}
				current_knot = target
				current_step_index = 0
			_:
				return {"type": "end"}

	return {"type": "end"}

func choose(index: int) -> Dictionary:
	var knot_steps: Array = knots.get(current_knot, [])
	if current_step_index <= 0:
		return {"type": "end"}

	var step: Dictionary = knot_steps[current_step_index - 1]
	var choices: Array = step.get("choices", [])
	if index < 0 or index >= choices.size():
		return {"type": "end"}

	var choice: Dictionary = choices[index]
	var target := str(choice.get("target", ""))
	if target == "END":
		return {"type": "end"}
	if not knots.has(target):
		push_error("InkStoryRunner: unknown choice target '%s'." % target)
		return {"type": "end"}

	current_knot = target
	current_step_index = 0
	return continue_story()

func _parse_choice_text(line: String) -> String:
	var start := line.find("[")
	var ending := line.rfind("]")
	if start == -1 or ending == -1 or ending <= start:
		return line.trim_prefix("* ").strip_edges()
	return line.substr(start + 1, ending - start - 1).strip_edges()

func _parse_dialogue_line(line: String, knot_name: String, line_index: int) -> Dictionary:
	var placeholder := "__INK_ESCAPED_HASH__"
	var sanitized_line := line.replace("\\#", placeholder)
	var segments := sanitized_line.split(" #")
	var spoken := segments[0].strip_edges()
	var tags := {}

	for i in range(1, segments.size()):
		var chunk := segments[i].strip_edges()
		var separator := chunk.find(":")
		if separator == -1:
			continue
		var key := chunk.substr(0, separator).strip_edges().to_lower()
		var value := chunk.substr(separator + 1).strip_edges()
		tags[key] = value

	var speaker := ""
	var text := spoken
	var spoken_separator := spoken.find(":")
	if spoken_separator != -1:
		speaker = spoken.substr(0, spoken_separator).strip_edges().to_lower()
		text = spoken.substr(spoken_separator + 1).strip_edges()

	text = text.replace(placeholder, "#")

	return {
		"type": STEP_LINE,
		"id": "%s_line_%03d" % [knot_name, line_index],
		"knot": knot_name,
		"speaker": speaker,
		"text": text,
		"tags": tags
	}
