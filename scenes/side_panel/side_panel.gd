extends Node2D
class_name SidePanel
var debug := true

@export var rack_sidebar_scene := preload("res://scenes/rack_sidebar/rack_sidebar.tscn")

@onready var top_rack = $VBoxContainer/TopRack/MainRack
@onready var bottom_rack = $VBoxContainer/BottomRack

# sizing
var ONE_HP_IN_PIXELS: int = 12 
var ANCHOR_POINTS_PER_HP: int = 4
var temp_unit_total = 79

var active_rack
var active_rack_sidebar

var all_racks = []
var all_racks_sidebar = []

## If the side panel is being rendered
var shown := false

## The PackedScene of the module being placed
var placing_module: PackedScene
## The instantiated module being placed at the closest anchor to the mouse position
var placing_module_instance

# currently unused
# var mouse_over_rack

var current_available_anchor_points = []
var candidate_placement_node

# All jacks on all modules
var _all_inputs_jacks = []
var _all_output_jacks = []

# For cable visualization
var CableScene := preload("res://scenes/DynamicCable/DynamicCable.tscn")
var current_cable: Node = null
var cables: Array = []

func _ready():
	# for now, always add the top rack to all_racks
	all_racks_sidebar.append(top_rack)
	top_rack.mouse_entered_rack.connect(_set_mouse_over_rack)
	top_rack.mouse_exited_rack.connect(_remove_mouse_over_rack)

	var temp_all_world_racks = get_tree().get_nodes_in_group("Racks")
	for world_rack in temp_all_world_racks:
		all_racks.append(world_rack)
		var related_rack_sidebar = _spawn_rack_sidebar_and_attack_to_rack(world_rack)
		all_racks_sidebar.append(related_rack_sidebar)
		related_rack_sidebar.mouse_entered_rack.connect(_set_mouse_over_rack)
		related_rack_sidebar.mouse_exited_rack.connect(_remove_mouse_over_rack)


func _set_mouse_over_rack(_rack):
	pass

func _remove_mouse_over_rack():
	pass

#region input
# for now, run _temp_module_initiation_intermediate when z/x/c keys are pressed
#   this is a placeholder for the inventory system 
# refactor all input naming
func _input(event):
	if not shown: return
	if event.is_action_pressed("z") or event.is_action_pressed("x") or event.is_action_pressed("c"):
		_temp_module_initiation_intermediate(event)
	elif event.is_action_pressed("space"):
		print("space pressed")
		_handle_initiate_cable_placement()
	elif event is InputEventMouseMotion: 
		_module_placement()
	elif event.is_action_pressed("left_click") and placing_module_instance:
		_place_module()
#endregion

#region module
################################################
#              Module Management               *
################################################


# this will be unnecessary once an inventory system is implemented
func _temp_module_initiation_intermediate(event):
	# -------------- FOR TESTING - REMOVE --------------#
	var new_module = null

	if event.is_action_pressed("z"):
		_clear_placing_module()
		new_module = preload("res://scenes/module/Modules/radio-patch-1/radio-patch-1.tscn")

	if event.is_action_pressed("x"):
		_clear_placing_module()
		new_module = preload("res://scenes/module/Modules/atten-2/atten_2.tscn")

	if event.is_action_pressed("c"):
		_clear_placing_module()
		new_module = preload("res://scenes/module/Modules/osc-2/osc_2.tscn")

	if new_module:
		_module_initiation(new_module)


## Instantiates the module to be placed so it can be moved around with the mouse
func _module_initiation(module):
	if module:
		placing_module = module
		placing_module_instance = module.instantiate()
		set_valid_anchor_points()
		add_child(placing_module_instance)
		_module_placement()


## Handles moving the placing_module_instance at the closest valid anchor point to the mouse
func _module_placement():
	if not placing_module_instance: return

	# get closest anchor to mouse
	var mouse_pos = get_global_mouse_position()
	var mouse_off = Vector2(-(placing_module_instance.width_hp * ONE_HP_IN_PIXELS * 2), 0)
	var placement_pos = mouse_pos + mouse_off
	var closest_anchor = $TopLeftAnchor
	var closest_dist = INF
	for anchor in current_available_anchor_points:
		var dist = placement_pos.distance_to(anchor.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_anchor = anchor
			candidate_placement_node = anchor
	
	placing_module_instance.global_position = closest_anchor.global_position


## Finds rack related to candidate anchor and calls _load_module() on it, passing
## the placing_module
func _place_module():
	if not placing_module_instance: return
	var rack_of_active_anchor = get_parent_in_group(candidate_placement_node, 'RacksSidebar')
	if not candidate_placement_node or not rack_of_active_anchor: return
	var new_module = rack_of_active_anchor._load_module(placing_module, candidate_placement_node)


	# set signals of jacks connected to the module
	_all_inputs_jacks.append(new_module.inputs)
	_all_output_jacks.append(new_module.outputs)
	
	for input_jack in new_module.inputs:
		if input_jack is Jack:
			if input_jack.jack_clicked.is_connected(_on_jack_clicked):
				input_jack.jack_clicked.disconnect(_on_jack_clicked)
			input_jack.jack_clicked.connect(_on_jack_clicked)
			print(input_jack, " connections: ", input_jack.jack_clicked.get_connections().size())

			
	for output_jack in new_module.outputs:
		if output_jack is Jack:
			if output_jack.jack_clicked.is_connected(_on_jack_clicked):
				output_jack.jack_clicked.disconnect(_on_jack_clicked)
			output_jack.jack_clicked.connect(_on_jack_clicked)
			print(output_jack, " connections: ", output_jack.jack_clicked.get_connections().size())


	_clear_all_candidate_anchors()
	placing_module_instance.queue_free()
	placing_module_instance = null
	current_available_anchor_points = []


## Clears the placing_module instance if it exists
func _clear_placing_module() -> void:
	if placing_module_instance:
		placing_module_instance.queue_free()
		placing_module_instance = null
		placing_module = null
		_clear_all_candidate_anchors()

## Clears all candidate anchors from all racks
func _clear_all_candidate_anchors():
	for rack in all_racks_sidebar:
		rack._clear_candidate_anchors()


## Finds and sets all valid anchor points from all available racks
func set_valid_anchor_points():
	if placing_module and placing_module_instance:
		current_available_anchor_points = get_all_anchor_points(placing_module_instance.width_hp)


## Gets all valid anchor points of all available racks
func get_all_anchor_points(width_hp: int) -> Array:
	var anchors = []

	anchors.append_array(top_rack.get_candidate_anchors(width_hp))

	if active_rack_sidebar:
		anchors.append_array(active_rack_sidebar.get_candidate_anchors(width_hp))
	
	return anchors


## Handles instantiating rack_sidebars and attaching them to the world-level racks
func _spawn_rack_sidebar_and_attack_to_rack(rack):
	var rack_instance = rack_sidebar_scene.instantiate()
	self.add_child(rack_instance)
	rack_instance.related_world_rack = rack
	rack_instance.position = bottom_rack.position
	rack_instance.is_main_rack = false
	rack_instance.set_frozen(true)
	return rack_instance


## Runs when the player moves to or away from a world-level rack. 
## active_rack_sidebar determines which rack to display in the lower position
func update_active_rack(rack):
	print('active rack: ', rack)
	active_rack = rack
	if not rack:
		active_rack_sidebar = null
		# force update so if candidate anchor was on a rack that was just removed
		# we move it to an active rack
		set_valid_anchor_points()
		_module_placement()
	else:
		for rack_sidebar in all_racks_sidebar:
			if rack_sidebar.related_world_rack == rack:
				active_rack_sidebar = rack_sidebar
	
	_freeze_or_unfreeze_racks()
	set_valid_anchor_points()


## Freezes racks that the player isn't near so they are not rendered or interactable
func _freeze_or_unfreeze_racks():
	for rack_sidebar in all_racks_sidebar:
		# skip main rack so it isn't cleared
		if rack_sidebar.is_main_rack: continue
		
		rack_sidebar.set_frozen(rack_sidebar != active_rack_sidebar)


## Returns the parent of a node that is in a given group
func get_parent_in_group(_node, _group_name):
	var checking = _node
	var parent_of_class = null
	while not parent_of_class:
		var parent = checking.get_parent()
		if not parent: break
		else:
			if parent.is_in_group(_group_name):
				parent_of_class = parent
	return parent_of_class
#endregion

#region cable
################################################
#               Cable Management               *
################################################
var _candidate_jack_connection = null
var CABLE_SCALE = 3.0


func _handle_initiate_cable_placement() -> void:
	if current_cable:
		_destroy_current_cable()
	else:
		_create_new_cable()


func _destroy_current_cable() -> void:
	if current_cable:
		current_cable.queue_free()


func _create_new_cable() -> void:
	current_cable = CableScene.instantiate()
	add_child(current_cable)


func _on_jack_clicked(jack) -> void:
	######################################################
	#                       Scenario 1                   #
	#                  There is no candidate             #
	#                Set current to candidate            #
	######################################################
	if _candidate_jack_connection == null:
		print("setting candidate to ", jack, " - in: ", jack.is_input)
		_candidate_jack_connection = jack
		current_cable.place_a(jack.global_position)
		return
		
	else:
		print("candidate is input: ", _candidate_jack_connection.is_input)
		print("selected is input: ", jack.is_input)

		###################################################
		#                   Scenario 2                    #
		#         Jack is same type as candidate          #
		#        Update candidate to new selection        #
		###################################################
		if (
			(jack.is_input and _candidate_jack_connection.is_input) or
			(not jack.is_input and not _candidate_jack_connection.is_input)
		):
			print('cannot connect inputs or outputs together')
			current_cable.place_a(jack.global_position)
			return

		###################################################
		#                   Scenario 3                    #
		#             Valid type but too far              #
		#              Print error (for now)              #
		###################################################
		if _candidate_jack_connection.global_position.distance_to(jack.global_position) > current_cable.total_length_in_pixels * CABLE_SCALE:
			print("too far")
			return

		
		###################################################
		#                   Scenario 4                    #
		#            One input and one output             #
		#          Place cable and make connection        #
		###################################################
		var _out
		var _in
		if _candidate_jack_connection.is_input:
			_in = _candidate_jack_connection
		else:
			_out = _candidate_jack_connection
			
		if jack.is_input:
			_in = jack
		else:
			_out = jack

		current_cable.place_b(jack.global_position)
		_create_connection(_in, _out)


func _create_connection(in_jack, out_jack):
	# Add to list of cables and clear placing cable
	if current_cable:
		cables.append(current_cable)
		current_cable = null

	# Forward output values to input
	out_jack.output_value_changed.connect(func(_n, val):
		in_jack.set_value(val)
	)

	# Initialize immediately
	in_jack.set_value(out_jack.value)
	in_jack.connected = true
	out_jack.connected = true

	# Remove candidate
	_candidate_jack_connection = null



#endregion
