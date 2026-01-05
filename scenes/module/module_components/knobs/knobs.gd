extends Node2D
class_name Knob

# knob configs
@export var value: float = 0.5
@export var sensitivity: float = 0.003
@export var debug := false
@export var debug_label: Label

# set these values from child
var input_name: String
var angle_sprites: Array[Node]
var _is_over_knob := false

# state
var _is_dragging := false
var _last_mouse_y := 0.0

signal input_value_changed(name: String, value: float)

func _ready() -> void:
	if debug_label:
		debug_label.text = str(value)
	set_value(value, true)

func _process(_delta: float) -> void:
	if debug_label:
		debug_label.text = "%.2f" % value   # show two decimals
		
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _is_over_knob:
				_is_dragging = true
				_last_mouse_y = event.position.y
				get_viewport().set_input_as_handled()
		else:
			_is_dragging = false

	elif event is InputEventMouseMotion and _is_dragging:
		var dy = _last_mouse_y - event.position.y
		_last_mouse_y = event.position.y
		var new_value = clamp(value + dy * sensitivity, 0.0, 1.0)
		set_value(new_value)

func set_value(val: float, first: bool = false) -> void:
	if is_equal_approx(val, value) and not first:
		return
	value = val
	_draw_value(val)
	#if debug:
		#print("%.2f" % val)
	emit_signal("input_value_changed", input_name, value)

func _draw_value(val: float) -> void:
	if angle_sprites.is_empty():
		return
	var number_of_positions = angle_sprites.size()
	var index = int(clamp(val * float(number_of_positions - 1), 0, number_of_positions - 1))
	for s in angle_sprites:
		s.visible = false
	angle_sprites[index].visible = true

func set_angle_sprites(_angle_sprites: Array) -> void:
	angle_sprites = _angle_sprites

func set_is_over_knob(val: bool) -> void:
	var module_parent = find_parent_in_group(self, 'Modules')
	if module_parent: print('module_parent', module_parent.placing)
	if module_parent and not module_parent.placing:
		_is_over_knob = val
	pass

func find_parent_in_group(node: Node, group_name: String) -> Node:
	var p = node
	while p:
		if p.is_in_group(group_name):
			return p
		p = p.get_parent()
	return null
