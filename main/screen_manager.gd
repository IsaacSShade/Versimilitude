extends Control

# This exposes a variable to the inspector to be easily changed (think config?)
@export var start_screen: PackedScene
var current_screen: Node

# This function runs once the node enters the scene tree, immediately navigates to starting screen
func _ready() -> void:
	go_to(start_screen)

func go_to(screen: PackedScene) -> void:
	# if a screen is currently on display, delete it
	if current_screen: 
		current_screen.queue_free()
		
	# Using our argument, create the node tree scene and put it into the current_screen variable
	current_screen = screen.instantiate()
	add_child(current_screen) # Adds the new scene to a child of the Screenmanager UI container
	
	get_tree().call_group("evidence_board", "set_toggle_enabled", current_screen.name != "TitleScreen")


	# If a screen emits "navigate(next_scene)" this script will listen and call "go_to"
	if current_screen.has_signal("navigate"):
		current_screen.connect("navigate", Callable(self, "go_to"))
