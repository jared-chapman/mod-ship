extends Node2D
class_name SidePanel
var debug := true

@export var rack_sidebar_scene := preload("res://scenes/rack_sidebar/rack_sidebar.tscn")

@onready var bottom_rack = $VBoxContainer/BottomRack

var active_rack
var active_rack_sidebar

var all_racks = []
var all_racks_sidebar = []

func _ready():
	# for now, always add the top rack to all_racks
	all_racks.append($VBoxContainer/TopRack/MainRack)

	var temp_all_world_racks = get_tree().get_nodes_in_group("Racks")
	for world_rack in temp_all_world_racks:
		all_racks.append(world_rack)
		var related_rack_sidebar = _spawn_rack_sidebar_and_attack_to_rack(world_rack)
		all_racks_sidebar.append(related_rack_sidebar)


func _process(_delta):
	pass

func _spawn_rack_sidebar_and_attack_to_rack(rack):
	var rack_instance = rack_sidebar_scene.instantiate()
	self.add_child(rack_instance)
	rack_instance.related_world_rack = rack
	rack_instance.position = bottom_rack.position
	rack_instance.set_frozen(true)
	return rack_instance

func update_active_rack(rack):
	active_rack = rack
	if not rack:
		print('leaving and setting to null')
		active_rack_sidebar = null
	else:
		for rack_sidebar in all_racks_sidebar:
			if rack_sidebar.related_world_rack == rack:
				active_rack_sidebar = rack_sidebar
	# if debug: print('active rack, ', active_rack)
	# if debug: print('active world rack, ', active_rack_sidebar)
	_freeze_or_unfreeze_racks()

func _freeze_or_unfreeze_racks():
	for rack_sidebar in all_racks_sidebar:
		# print('setting ', rack_sidebar, ' to ', 'true' if rack_sidebar == active_rack_sidebar else 'false')
		rack_sidebar.set_frozen(rack_sidebar != active_rack_sidebar)
