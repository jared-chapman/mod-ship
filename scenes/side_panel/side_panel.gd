extends Node2D
class_name SidePanel
var debug := true

@export var rack_sidebar_scene := preload("res://scenes/rack_sidebar/rack_sidebar.tscn")

@onready var top_rack = $VBoxContainer/TopRack/MainRack
@onready var bottom_rack = $VBoxContainer/BottomRack

var active_rack
var active_rack_sidebar

var all_racks = []
var all_racks_sidebar = []

var placing_module
var placing_module_instance

var mouse_over_rack

func _ready():
	# for now, always add the top rack to all_racks
	var main_sidebar_rack = $VBoxContainer/TopRack/MainRack
	all_racks_sidebar.append(main_sidebar_rack)
	main_sidebar_rack.mouse_entered_rack.connect(_set_mouse_over_rack)
	main_sidebar_rack.mouse_exited_rack.connect(_remove_mouse_over_rack)


	var temp_all_world_racks = get_tree().get_nodes_in_group("Racks")
	for world_rack in temp_all_world_racks:
		all_racks.append(world_rack)
		var related_rack_sidebar = _spawn_rack_sidebar_and_attack_to_rack(world_rack)
		all_racks_sidebar.append(related_rack_sidebar)
		related_rack_sidebar.mouse_entered_rack.connect(_set_mouse_over_rack)
		related_rack_sidebar.mouse_exited_rack.connect(_remove_mouse_over_rack)
		


func _process(_delta):
	pass

func _set_mouse_over_rack(rack):
	mouse_over_rack = rack
	print('mouse_over_rack ', mouse_over_rack)

func _remove_mouse_over_rack():
	mouse_over_rack = null
	print('mouse_over_rack cleared')

func _input(event):
	# var rack = all_racks_sidebar[0]
	var rack = mouse_over_rack
	_temp_module_placement(event, rack)

func _temp_module_placement(event, rack):
	# -------------- FOR TESTING - REMOVE --------------#
	if rack:
		if event.is_action_pressed("x"):
			placing_module = preload("res://scenes/module/Modules/atten-2/atten_2.tscn")
			rack.start_placing_module(placing_module)
			# _clear_placing_module()
			# if placing_module:
			# 	var instance = placing_module.instantiate()
			# 	instance.width_hp = 4
			# 	add_child(instance)
			# 	placing_module_instance = instance
				
		if event.is_action_pressed("c"):
			placing_module = preload("res://scenes/module/Modules/osc-2/osc_2.tscn")
			rack.start_placing_module(placing_module)
			# _clear_placing_module()

	# if placing_module:
	# 	var instance = placing_module.instantiate()
	# 	instance.width_hp = 4
	# 	add_child(instance)
	# 	placing_module_instance = instance

func _clear_placing_module() -> void:
	# clear existing placing module if it exists
	if placing_module_instance:
		placing_module_instance.queue_free()
		placing_module_instance = null
	for rack in all_racks_sidebar:
		rack._clear_candidate_anchors()

func _spawn_rack_sidebar_and_attack_to_rack(rack):
	var rack_instance = rack_sidebar_scene.instantiate()
	self.add_child(rack_instance)
	rack_instance.related_world_rack = rack
	rack_instance.position = bottom_rack.position
	rack_instance.is_main_rack = false
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
		# skip main rack so it isn't cleared
		if rack_sidebar.is_main_rack: continue
		
		rack_sidebar.set_frozen(rack_sidebar != active_rack_sidebar)


func _start_placing_module():
	pass
