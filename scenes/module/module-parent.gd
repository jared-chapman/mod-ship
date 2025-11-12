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
	inputs = $Inputs.get_children()
	outputs = $Outputs.get_children()

	print("Inputs: ", inputs)
	print("Outputs: ", outputs)

	for input_jack in inputs:
		var callable_in = Callable(self, "_on_input_signal_connection")
		if not input_jack.is_connected("input_value_changed", callable_in):
			input_jack.input_value_changed.connect(callable_in)

	for output_jack in outputs:
		var callable_out = Callable(self, "_on_output_signal_connection")
		if not output_jack.is_connected("output_value_changed", callable_out):
			output_jack.output_value_changed.connect(callable_out)

	

func _on_input_signal_connection(input_name, value):
	#print(input_name, " - ", value)
	pass

func _on_output_signal_connection(output_name, value):
	#print(output_name, ' - ', value)
	pass
