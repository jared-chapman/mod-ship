extends Node2D

@export var value: int = 50
@export var type: String = "small_1"
@export var sensitivity: float = 0.3 # higher = faster change

var _debug_rect: Rect2

signal knob_value_changed(name: String, value: int)

var knob_name := "default"
var current_sprite: Sprite2D
var angle_sprites: Array[Node]
var number_of_positions: int

var _is_dragging := false
var _last_mouse_y := 0.0
var _is_over_knob := false

func _ready() -> void:
	if type == "small_1":
		number_of_positions = 11
		current_sprite = find_child("SmallSprite", true, false)
		angle_sprites = current_sprite.get_children()
		
	_draw_value(value)
	
func _process(_delta: float) -> void:
	queue_redraw()

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
		var new_value = clamp(value + dy * sensitivity, 0, 100)
		set_value(int(new_value))

func set_value(val: int) -> void:
	if val == value:
		return
	value = val
	_draw_value(val)
	emit_signal("knob_value_changed", knob_name, value)

func _draw_value(val: int) -> void:
	var index = int(clamp(float(val) / 100.0 * (number_of_positions - 1), 0, number_of_positions - 1))
	for s in angle_sprites:
		s.visible = false
	angle_sprites[index].visible = true
	
func _draw() -> void:
	if _debug_rect:
		var local_rect = Rect2(
			to_local(_debug_rect.position),
			_debug_rect.size
		)
		draw_rect(local_rect, Color(0.986, 0.0, 0.0, 0.3), false)

#func _is_over_knob() -> bool:
	#if not current_sprite or not current_sprite.texture:
		#return false
#
	#var tex: Texture2D = current_sprite.texture
#
	## Define the clickable area in the sprite's own local coordinates
	#var rect = Rect2(-tex.get_size() * 0.5, tex.get_size())
#
	## Convert the passed-in mouse position to the sprite's local space
	##var global_mouse = get_global_transform().xform(mouse_pos)
	#var local_mouse = current_sprite.to_local(get_global_mouse_position())
	#_debug_rect = Rect2(
		#to_local(current_sprite.global_position + rect.position),
		#rect.size
	#)
#
	#return rect.has_point(local_mouse)


func _on_area_2d_mouse_entered() -> void:
	print("Over")
	_is_over_knob = true


func _on_area_2d_mouse_exited() -> void:
	print("Left")
	_is_over_knob = false
