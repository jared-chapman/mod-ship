extends Node2D

# @onready var room_container = $RoomContainer
@onready var player = $Player
@onready var ui = $CanvasLayer/SidePanel
@export var room_scene: PackedScene

func _ready() -> void:
	# Create one room
	# var room = room_scene.instantiate()
	# room_container.add_child(room)
	# room.position = Vector2(0, 0)

	$Player.toggle_rack_panel.connect(_on_toggle_rack_panel)


func _process(_delta: float) -> void:
	pass

func _on_toggle_rack_panel() -> void:
	$RacksCanvasLayer.visible = !$RacksCanvasLayer.visible
