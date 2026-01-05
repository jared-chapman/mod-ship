extends Node2D
class_name Switch

# knob configs
@export var value := 0

# set these values from child
var input_name: String
var _is_over_switch := false
var on_sprite: Sprite2D
var off_sprite: Sprite2D


signal input_value_changed(_name: String, value: int)

func _ready() -> void:
	set_value(value)

func _process(_delta: float) -> void:
	pass
		
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _is_over_switch:
				var new = 0
				if value == 0:
					new = 1
				print("setting value - ", value)
				set_value(new)

func set_input_name(_name):
	print('setting name to ', _name)
	input_name = _name

func set_value(val: int) -> void:
	if is_equal_approx(val, value):
		return
	value = val
	_draw_value(val)
	emit_signal("input_value_changed", input_name, value)

func _draw_value(val: int) -> void:
	if on_sprite and off_sprite:
		if val == 0:
			on_sprite.visible = false
			off_sprite.visible = true
		else:
			on_sprite.visible = true
			off_sprite.visible = false


func set_is_over_switch(val: bool) -> void:
	_is_over_switch = val
