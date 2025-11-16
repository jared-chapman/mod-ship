extends Node2D

@onready var room_container = $RoomContainer
@onready var player = $Player
@onready var ui = $CanvasLayer/SidePanel
@export var room_scene: PackedScene

func _ready() -> void:
	# Create one room
	var room = room_scene.instantiate()
	room_container.add_child(room)
	room.position = Vector2(0, 0)


func _process(_delta: float) -> void:
	pass
