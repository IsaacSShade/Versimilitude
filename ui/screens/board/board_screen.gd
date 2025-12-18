extends Control
signal navigate(next: PackedScene)

@export var next_screen: PackedScene

func _on_continue_pressed() -> void:
	navigate.emit(next_screen)
