extends Node2D
var debug := true

# @onready var room_container = $RoomContainer
@onready var player = $Player
# @onready var ui = $CanvasLayer/SidePanel
@onready var side_panel = $SidePanel
@export var room_scene: PackedScene


func _ready() -> void:
	$Player.toggle_rack_panel.connect(_on_toggle_rack_panel)
	$ShipInterior.active_rack_changed.connect(_active_rack_changed)

	$Player/WorldCamera.make_current()


func _process(_delta: float) -> void:
	pass

func _on_toggle_rack_panel() -> void:
	var shown = !$RacksCanvasLayer/SidePanel.visible
	$RacksCanvasLayer/SidePanel.visible = shown
	$RacksCanvasLayer.visible = shown
	$RacksCanvasLayer/SidePanel.shown = shown

	if shown:
		$RacksCanvasLayer/SidePanel/RackCamera.make_current()
	else:
		$Player/WorldCamera.make_current()

func _active_rack_changed(rack):
	$RacksCanvasLayer/SidePanel.active_rack = rack
	side_panel.update_active_rack(rack)
