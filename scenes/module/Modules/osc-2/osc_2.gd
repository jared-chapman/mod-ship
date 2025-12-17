extends ModuleParent

var speed
var mode_select
var sin_out
var sqr_out

var _base_mod = 0.5
var _mode_mod = 30
var _slowest = 0.01

var _phase: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("hi")
	setup()
	speed = inputs[0]
	mode_select = inputs[1]
	sin_out = outputs[0]
	sqr_out = outputs[1]

	width_hp = 4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mode = mode_select.value
	var speed_val = speed.value
	var freq = speed_val * _base_mod + _slowest
	if mode == 1:
		freq *= _mode_mod
	sin_out.set_value(_process_wave(delta, "sin", freq))
	#sin_out.set_sig
	sqr_out.set_value(_process_wave(delta, "sqr", freq))
	
	pass
	

func _process_wave(delta: float, shape: String, freq: float) -> float:
	# Advance phase by frequency
	_phase += delta * freq * TAU  # TAU = 2π

	# Wrap around
	if _phase > TAU:
		_phase -= TAU
	match shape:
		"sin":
			var raw = sin(_phase)  # -1 to 1
			var normalized = (raw + 1.0) * 0.5  # 0 to 1
			return normalized
		"sqr":
			
			var normalized = 0
			if _phase > PI:
				normalized = 1
			return normalized
		_:
			pass
	return 0.0
