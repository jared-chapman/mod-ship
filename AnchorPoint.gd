extends Node2D

@export var available: bool = true
@export var candidate: bool = false
@export var locked: bool = false
@export var index: int = -1
@export var debug_mode: bool = true  # 👈 toggle this in the editor or via code

const DOT_RADIUS := 4.0

func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	if debug_mode:
		queue_redraw()  # ensure it updates if availability changes

func _draw() -> void:
	if not debug_mode:
		return  # do nothing if debug disabled

	var color: Color = Color.GREEN if available else Color.BLUE if candidate else Color.RED
	draw_circle(Vector2.ZERO, DOT_RADIUS, color)
