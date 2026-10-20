extends ModuleParent

var in_1
var in_2
var in_3

var jack_1
var jack_2
var jack_3

var out_1
var out_2
var out_3

func _ready() -> void:
	setup()
	in_1   = inputJacks[0]
	jack_1 = inputKnobs[0]
	out_1  = outputJacks[0]
	
	in_2   = inputJacks[1]
	jack_2 = inputKnobs[1]
	out_2  = outputJacks[1]
	
	in_3   = inputJacks[2]
	jack_3 = inputKnobs[2]
	out_3  = outputJacks[2]

	width_hp = 4


func _process(_delta: float) -> void:
	# normal the inputs
	if not in_2.connected:
		in_2.set_value_from_module({"volt": out_1.value.volt})
		
	if not in_3.connected:
		in_3.set_value_from_module({"volt": out_2.value.volt})
	
	out_1.set_value_from_module({"volt": in_1.value.volt * jack_1.value})
	out_2.set_value_from_module({"volt": in_2.value.volt * jack_2.value})
	out_3.set_value_from_module({"volt": in_3.value.volt * jack_3.value})
	
