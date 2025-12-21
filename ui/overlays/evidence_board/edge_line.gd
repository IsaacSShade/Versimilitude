extends Node2D

@onready var line: Line2D = $Line

var a_inst: int = 0
var b_inst: int = 0

func init_edge(a: int, b: int) -> void:
	a_inst = a
	b_inst = b

func set_endpoints_local(a: Vector2, b: Vector2) -> void:
	# points are in the Line2D's local space (same as EdgeLine local)
	line.points = PackedVector2Array([a, b])
