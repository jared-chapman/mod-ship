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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Atten-2 ready")
	setup()
	in_1   = inputs[3]
	jack_1 = inputs[0]
	out_1  = outputs[0]
	
	in_2   = inputs[4]
	jack_2 = inputs[1]
	out_2  = outputs[1]
	
	in_3   = inputs[5]
	jack_3 = inputs[2]
	out_3  = outputs[2]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# normal the inputs
	if not in_2.connected:
		in_2.set_value(out_1.value)
		
	if not in_3.connected:
		in_3.set_value(out_2.value)
	
	out_1.set_value(in_1.value * jack_1.value)
	out_2.set_value(in_2.value * jack_2.value)
	out_3.set_value(in_3.value * jack_3.value)
	
