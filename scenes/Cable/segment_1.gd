extends RigidBody2D


@export var prev: Node2D
@export var next: Node2D

func _process(_delta):
	if not prev or not next:
		return

	var dir = (next.global_position - prev.global_position).normalized()
	$Sprite2D.rotation = dir.angle()
