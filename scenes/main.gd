extends Node2D
var debug := true

# @onready var room_container = $RoomContainer
@onready var player = $Player
# @onready var ui = $CanvasLayer/SidePanel
@onready var sidePanel = $RacksCanvasLayer/SidePanel
@export var room_scene: PackedScene


func _ready() -> void:
	$Player.toggle_rack_panel.connect(_on_toggle_rack_panel)
	$ShipInterior.active_rack_changed.connect(_active_rack_changed)


func _process(_delta: float) -> void:
	pass

func _on_toggle_rack_panel() -> void:
	$RacksCanvasLayer.visible = !$RacksCanvasLayer.visible

func _active_rack_changed(rack):
	# $RacksCanvasLayer/SidePanel.active_rack = rack
	sidePanel.update_active_rack(rack)
