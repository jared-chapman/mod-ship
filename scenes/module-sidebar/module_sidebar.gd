extends Node2D

@export var module: PackedScene
@export var test_with_default = true
var module_instance
@export var module_width_hp = 4

@export var placing: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ready")
	if test_with_default and not module:
		print("setting module")
		module = load("res://scenes/module-sidebar/Modules/Atten-1.tscn")
	
	if module:
		print("instantiating")
		print(module)
		module_instance = module.instantiate()
		add_child(module_instance)
		module_width_hp = module_instance.width_hp || 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
