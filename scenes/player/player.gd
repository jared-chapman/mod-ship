extends CharacterBody2D

class_name player_

@export var speed := 200.0

func _ready():
	add_to_group("player")


func _physics_process(_delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = input.normalized() * speed
	move_and_slide()
