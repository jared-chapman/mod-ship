extends Node2D
class_name Module

@export var module_name: String = "Reactor"
@export var power_draw: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = module_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
