extends Node2D
class_name ModuleParent

@export var width_hp: int
@export var inputs = []
@export var outputs = []
@export var tl_screw_offset = Vector2(9, 9)
@export var placing := true

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass

func setup() -> void:
	var input_scenes = $Inputs.get_children()
	inputs = input_scenes
	print(inputs)
	for i in inputs:
		i.input_value_changed.connect(Callable(self, "_on_input_signal_connection"))
		
	var output_scenes = $Outputs.get_children()
	outputs = output_scenes
	print(outputs)
	for i in outputs:
		i.output_value_changed.connect(Callable(self, "_on_output_signal_connection"))

	

func _on_input_signal_connection(input_name, value):
	#print(input_name, " - ", value)
	pass

func _on_output_signal_connection(output_name, value):
	#print(output_name, ' - ', value)
	pass
