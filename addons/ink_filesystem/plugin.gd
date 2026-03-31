@tool
extends EditorPlugin

const OTHER_EXTENSIONS_SETTING := "docks/filesystem/other_file_extensions"
const TEXT_EXTENSIONS_SETTING := "docks/filesystem/textfile_extensions"
const INK_EXTENSION := "ink"

func _enable_plugin() -> void:
	var editor_settings := get_editor_interface().get_editor_settings()
	_append_extension(editor_settings, OTHER_EXTENSIONS_SETTING)
	_append_extension(editor_settings, TEXT_EXTENSIONS_SETTING)

func _append_extension(editor_settings: EditorSettings, setting_name: String) -> void:
	var raw_value := ""
	if editor_settings.has_setting(setting_name):
		raw_value = str(editor_settings.get_setting(setting_name))
	var extensions := PackedStringArray()

	for part in raw_value.split(","):
		var cleaned := part.strip_edges()
		if cleaned != "":
			extensions.append(cleaned)

	if not extensions.has(INK_EXTENSION):
		extensions.append(INK_EXTENSION)
		editor_settings.set_setting(setting_name, ",".join(extensions))
