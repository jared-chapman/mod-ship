extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_inputs(event):
	if event.is_action_pressed('UP'):
		_spawn_module('VCO')

func _spawn_module(module) -> void:
	var m
	if module == 'VCO':
		m = preload("res://scenes/module/Modules/osc-2/osc_2.tscn")