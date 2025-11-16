extends Node2D

class_name AnchorPoint

@export var available: bool = true
@export var candidate: bool = false
@export var locked: bool = false
@export var index: int = -1

# debug will color / make visible
@export var debug: bool = true

const DOT_RADIUS := 4.0

func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	if debug:
		queue_redraw()  # ensure it updates if availability changes

func _draw() -> void:
	if not debug:
		return  # do nothing if debug disabled

	var color: Color = Color.GREEN if available else Color.BLUE if candidate else Color.RED
	draw_circle(Vector2.ZERO, DOT_RADIUS, color)
