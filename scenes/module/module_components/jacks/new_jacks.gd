extends Node
class_name NewJack

@export var is_input: bool

var value: Dictionary = {
	"volt" = 0,
	"amp" = 0
}
var focused: bool

signal value_changed(jack: NewJack, value: float)

func _ready():
	set_value(value, true)

func _process(delta):
	pass

func set_value(val, first: bool = false) -> void:
	if (val.volt == value.volt) \
	and (val.amp == value.amp) \
	and (not first):
		return

	value = val
	emit_signal("value_changed", self, value)

func set_focused(f):
	focused = f
	if f:
		$Sprite2D2.modulate = Color.YELLOW
	else:
		$Sprite2D2.modulate = Color.WHITE
		
