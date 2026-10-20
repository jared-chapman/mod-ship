extends Node
class_name Jack

var _debug_label: Label

@export var is_input: bool

var module := ModuleParent
var connected := false
var focused: bool

var value: Dictionary = {
	"volt": 0,
	"amp": 0,
	"freq": 0,
	"shape": "",
	"power": 0
}

signal value_changed(value)

func _ready():
	Globals.debug_changed.connect(_on_debug_changed)
	_initiate_debug_label()
	_set_value(value)
	
func _process(_delta):
	_handle_debug_label()
	
func _initiate_debug_label():
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.7)
	_debug_label = Label.new()
	_debug_label.position = Vector2(-3, -10)
	_debug_label.scale = Vector2(0.2, 0.2)
	_debug_label.add_theme_stylebox_override("normal", bg)
	_debug_label.visible = Globals.debug
	add_child(_debug_label)
	
func _handle_debug_label():
	_debug_label.text = str("%.2f" % value.volt)
		
func _on_debug_changed(_value):
	_debug_label.visible = _value

# Accepts a dictionary and only updates passed in keys
# Missing keys do not overwrite existing values
func _set_value(new_value) -> void:
	for key in new_value.keys():
		value[key] = new_value[key]
	if !is_input and connected:
		emit_signal("value_changed", value)

func _set_value_from_signal(v):
	_set_value(v)
		
func set_value_from_module(v):
	_set_value(v)


func set_focused(f):
	focused = f
	if f:
		$Sprite2D.modulate = Color.YELLOW
	else:
		$Sprite2D.modulate = Color.WHITE
		
func establish_connection(other):
	connected = true
	if is_input:
		_connect_to_output(other)
	else:
		_connect_to_input(other)

func _connect_to_input(other):
	pass

func _connect_to_output(other):
	print(other.value_changed)
	other.value_changed.connect(_set_value_from_signal)

func disconnect_from_cable():
	connected = false
	for s in get_incoming_connections():
		s.disconnect
		
