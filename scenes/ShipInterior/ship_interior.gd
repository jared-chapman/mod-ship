extends Node2D
var debug := true

var racks := []

# The rack the player is closest to, and that should appear in the sidebar
var active_rack
signal active_rack_changed(rack)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get all Racks
	racks = get_tree().get_nodes_in_group("Racks")

	for rack in racks:
		rack.player_entered_rack.connect(_on_player_entered_rack)
		rack.player_exited_rack.connect(_on_player_exited_rack)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_entered_rack(rack):
	active_rack = rack
	active_rack_changed.emit(rack)

func _on_player_exited_rack(rack):
	active_rack = null
	active_rack_changed.emit(null)
