extends Node2D
@export var frozen = true

var is_main_rack = true

var ONE_HP_IN_PIXELS: int = 2
var ANCHOR_POINTS_PER_HP: int = 4
var temp_unit_total = 79

var _all_inputs := []
var _all_outputs := []

var _candidate_jack_connection = null

var anchor_point = preload("res://scripts/anchor_point.gd")
var anchors = []

var related_world_rack = null

## For cable visualization
var CableScene := preload("res://scenes/DynamicCable/DynamicCable.tscn")
var current_cable: Node = null
var cables: Array = []

var GLOBAL_SCALE = 3

signal mouse_entered_rack(rack)
signal mouse_exited_rack(rack)

func _ready() -> void:
	# spawn all possible anchor points
	# this could stand to be refactored
	$TopLeftAnchor.available = true
	$TopLeftAnchor.index = 0
	var prefix = "top-anchor-" if is_main_rack else "bot-anchor"
	for i in temp_unit_total:
		var anchor = anchor_point.new()
		anchor.name = "%s%d" % [prefix, (i + 1)]
		anchor.position = Vector2($TopLeftAnchor.position.x + (ONE_HP_IN_PIXELS * i + 1), $TopLeftAnchor.position.y)
		anchor.available = true
		anchor.index = i + 1
		anchors.append(anchor)
		add_child(anchor)

	$Area2D.mouse_entered.connect(_on_mouse_entered_rack)
	$Area2D.mouse_exited.connect(_on_mouse_exited_rack)


## Creates an array of all available anchor points for a given module width
func get_candidate_anchors(w: int) -> Array:
	var candidates = []
	var last_anchor_index = temp_unit_total - (w * ANCHOR_POINTS_PER_HP) + 2

	for anchor in anchors:
		if anchor.index > last_anchor_index:
			continue
			
		var valid = true
		var sub_anchors = anchors.slice(anchor.index - 1, anchor.index + (w * ANCHOR_POINTS_PER_HP) - 1)
		for a in sub_anchors:
			if not a.available: 
				valid = false
				anchor.candidate = false
		
		if valid:
			anchor.candidate = true
			candidates.append(anchor)
	return candidates
		

## Instantiates a module and loads it into the rack
func _load_module(module_scene: PackedScene, anchor):
	var module_instance = module_scene.instantiate()
	var width = module_instance.width_hp
	add_child(module_instance)
	module_instance.position = anchor.position
	module_instance.placing = false

	_disable_anchors_by_index_and_hp(anchor.index, width)

	if module_instance is ModuleParent:
		module_instance.setup()

	return module_instance
		
	# _all_inputs.append(module_instance.inputs)
	# _all_outputs.append(module_instance.outputs)
	
	# for input_jack in module_instance.inputs:
	# 	if input_jack is Jack:
	# 		if input_jack.jack_clicked.is_connected(_on_jack_clicked):
	# 			input_jack.jack_clicked.disconnect(_on_jack_clicked)
	# 		input_jack.jack_clicked.connect(_on_jack_clicked)
	# 		print(input_jack, " connections: ", input_jack.jack_clicked.get_connections().size())

			
	# for output_jack in module_instance.outputs:
	# 	if output_jack is Jack:
	# 		if output_jack.jack_clicked.is_connected(_on_jack_clicked):
	# 			output_jack.jack_clicked.disconnect(_on_jack_clicked)
	# 		output_jack.jack_clicked.connect(_on_jack_clicked)
	# 		print(output_jack, " connections: ", output_jack.jack_clicked.get_connections().size())


## Disables anchor points that would be covered by a module
func _disable_anchors_by_index_and_hp(index: int, hp: int):
	var last_index = index + (hp * ANCHOR_POINTS_PER_HP) - 1
	for anchor in anchors:
		if anchor.index >= index and anchor.index <= last_index:
			anchor.available = false
			anchor.locked = true


## Clears all candidate anchors so they can be recalculated
func _clear_candidate_anchors() -> void:
	for a in anchors:
		a.candidate = false

## Freezes or unfreezes rack to hide and stop physics
func set_frozen(val):
	frozen = val
	self.visible = !val

func _on_mouse_entered_rack():
	mouse_entered_rack.emit(self)

func _on_mouse_exited_rack():
	mouse_exited_rack.emit()


# the below logic should be moved into the side_panel component
# so modules from different racks can be connected

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

# func _on_jack_clicked(jack) -> void:

# 	######################################################
# 	#                       Scenario 1                   #
# 	#                  There is no candidate             #
# 	#                Set current to candidate            #
# 	######################################################
# 	if _candidate_jack_connection == null:
# 		print("setting candidate to ", jack, " - in: ", jack.is_input)
# 		_candidate_jack_connection = jack
# 		current_cable.place_a(jack.global_position)
# 		return
		
# 	else:
# 		print("candidate is input: ", _candidate_jack_connection.is_input)
# 		print("selected is input: ", jack.is_input)

# 		###################################################
# 		#                   Scenario 2                    #
# 		#         Jack is same type as candidate          #
# 		#        Update candidate to new selection        #
# 		###################################################
# 		if (
# 			(jack.is_input and _candidate_jack_connection.is_input) or
# 			(not jack.is_input and not _candidate_jack_connection.is_input)
# 		):
# 			print('cannot connect inputs or outputs together')
# 			current_cable.place_a(jack.global_position)
# 			return

# 		###################################################
# 		#                   Scenario 3                    #
# 		#             Valid type but too far              #
# 		#              Print error (for now)              #
# 		###################################################
# 		if _candidate_jack_connection.global_position.distance_to(jack.global_position) > current_cable.total_length_in_pixels * GLOBAL_SCALE:
# 			print("too far")
# 			return

		
# 		###################################################
# 		#                   Scenario 4                    #
# 		#            One input and one output             #
# 		#          Place cable and make connection        #
# 		###################################################
# 		var _out
# 		var _in
# 		if _candidate_jack_connection.is_input:
# 			_in = _candidate_jack_connection
# 		else:
# 			_out = _candidate_jack_connection
			
# 		if jack.is_input:
# 			_in = jack
# 		else:
# 			_out = jack

# 		current_cable.place_b(jack.global_position)
# 		_create_connection(_in, _out)
