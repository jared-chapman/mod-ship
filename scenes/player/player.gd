extends CharacterBody2D

class_name player_


signal request_place_module(position: Vector2)
signal request_clear_rack(position: Vector2)
@export var speed := 200.0

var current_rack: Rack = null

func _ready():
	add_to_group("player")


func _physics_process(_delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	velocity = input.normalized() * speed
	move_and_slide()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"): # Enter key by default
		emit_signal("request_place_module", global_position)
		
	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("request_clear_rack", global_position)
