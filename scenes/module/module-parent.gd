extends Node2D
class_name ModuleParent

@export var width_hp: int = 4
@export var inputKnobs = []
@export var inputSwitches = []
@export var inputJacks = []
@export var outputJacks = []
@export var tl_screw_offset = Vector2(40, 40) #9, 9
@export var placing := true

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass

func setup() -> void:
	inputKnobs = $InputKnobs.get_children()
	inputSwitches = $InputSwitches.get_children()
	inputJacks = $InputJacks.get_children()
	outputJacks = $OutputJacks.get_children()

	print("InputJacks: ", inputJacks)
	print("OutputJacks: ", outputJacks)

	#for input_jack in inputs:
		#var callable_in = Callable(self, "_on_input_signal_connection")
		#if not input_jack.is_connected("input_value_changed", callable_in):
			#input_jack.input_value_changed.connect(callable_in)
#
	#for output_jack in outputs:
		#var callable_out = Callable(self, "_on_output_signal_connection")
		#if not output_jack.is_connected("output_value_changed", callable_out):
			#output_jack.output_value_changed.connect(callable_out)

func _get_inputs():
	if !inputJacks: return null
	return inputJacks

func _get_outputs():
	return outputJacks
	
func get_connections():
	return {
		'inputs': inputJacks,
		'outputs': outputJacks,
	}

func _on_input_signal_connection(input_name, value):
	#print(input_name, " - ", value)
	pass

func _on_output_signal_connection(output_name, value):
	#print(output_name, ' - ', value)
	pass
