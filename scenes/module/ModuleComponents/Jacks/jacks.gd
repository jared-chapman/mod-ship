extends Node
class_name Jack

@export var value := 0.5
@export var sig = {
	"is_wave": false,
	"freq": 0.5,
	"shape": "sin" ,
}

@export var is_input: bool
@export var debug: bool
@export var debug_value: int
@export var debug_label: Label

@export var debug_wave: String
@export var debug_freq: float

@export var connected: bool = false

var input_name: String
var _debug_phase: float = 0.0
var _is_over_jack := false

signal input_value_changed(name: String, value: float)
signal output_value_changed(name: String, value: float)
signal input_signal_changed(name: String, value)
signal output_signal_changed(name:String, value)
signal jack_clicked(jack: Jack)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_value(value, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if debug_label:
		debug_label.text = "%.2f" % value
	#if debug and debug_value != value:
		#set_value(debug_value)
	if debug and debug_wave:
		_process_debug_wave(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _is_over_jack:
			emit_signal("jack_clicked", self)


func set_value(val: float, first: bool = false) -> void:
	if val == value and not first:
		return
	value = val
	
	if is_input:
		emit_signal("input_value_changed", input_name, value)
	else:
		emit_signal("output_value_changed", input_name, value)

func set_sig(freq: float, shape: String) -> void:
	if is_input:
		emit_signal("input_signal_changed", input_name, sig)
	else:
		emit_signal("output_signal_changed", input_name, sig)
	
		

func _process_debug_wave(delta: float) -> void:
	# Advance phase by frequency
	_debug_phase += delta * debug_freq * TAU  # TAU = 2π

	# Wrap around
	if _debug_phase > TAU:
		_debug_phase -= TAU

	match debug_wave:
		"sin":
			var raw = sin(_debug_phase)  # -1 to 1
			var normalized = (raw + 1.0) * 0.5  # 0 to 1
			set_value(normalized)
		_:
			# Add other wave types here later (e.g. "square", "saw")
			pass
		
func set_is_over_jack(val: bool) -> void:
	_is_over_jack = val
