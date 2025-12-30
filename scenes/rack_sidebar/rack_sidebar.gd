extends Node2D

var loaded_modules = []
@export var default_test_module: PackedScene
var fill = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var placing_module: PackedScene = null
var placing_module_instance
@export var test_placing_module: PackedScene
@export var test_placing_module_2: PackedScene

var ONE_HP_IN_PIXELS: int = 12 
var ANCHOR_POINTS_PER_HP: int = 4
var temp_unit_total = 79

var _all_inputs := []
var _all_outputs := []

var _candidate_placement_node
var _candidate_jack_connection = null

var anchor_point = preload("res://scripts/anchor_point.gd")
var anchors = []
var _candidate_anchors = []

# For cable visualization
var CableScene := preload("res://scenes/DynamicCable/DynamicCable.tscn")
var current_cable: Node = null
var cables: Array = []

var GLOBAL_SCALE = 3


func _ready() -> void:
	# spawn all possible anchor points
	# anchors.append($TopLeftAnchor)
	$TopLeftAnchor.available = true
	$TopLeftAnchor.index = 0
	for i in temp_unit_total:
		var anchor = anchor_point.new()
		anchor.name = "anchor_%d" % (i + 1)
		anchor.position = Vector2($TopLeftAnchor.position.x + (ONE_HP_IN_PIXELS * i + 1), $TopLeftAnchor.position.y)
		anchor.available = true
		anchor.index = i + 1
		anchors.append(anchor)
		add_child(anchor)
	


func _process(_delta: float) -> void:
	pass


func _input(event):
	# -------------- FOR TESTING - REMOVE --------------#
	if event.is_action_pressed("x"):
		_clear_placing_module()
		placing_module = test_placing_module
		if placing_module:
			var instance = placing_module.instantiate()
			instance.width_hp = 4
			add_child(instance)
			placing_module_instance = instance
			
	if event.is_action_pressed("c"):
		_clear_placing_module()
		placing_module = test_placing_module_2
		if placing_module:
			var instance = placing_module.instantiate()
			instance.width_hp = 4
			add_child(instance)
			placing_module_instance = instance
	# -------------- FOR TESTING - REMOVE --------------#

	# while placing module
	if placing_module_instance:
		var module_width = placing_module_instance.width_hp
		if not _candidate_anchors:
			_set_candidate_anchors(module_width)

		# if we set candidate anchors and it's still null, there are no available slots
		if not _candidate_anchors:
			print("No room")
			_clear_placing_module()
			return
		
		# mouse position should be center of module
		var mouse_pos = get_global_mouse_position()
		var mouse_off = Vector2(-(placing_module_instance.width_hp * ONE_HP_IN_PIXELS * 2), 0)
		var placement_pos = mouse_pos + mouse_off
		var closest_anchor = $TopLeftAnchor
		var closest_dist = INF
		for anchor in _candidate_anchors:
			var dist = placement_pos.distance_to(anchor.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_anchor = anchor
				_candidate_placement_node = anchor
				
		placing_module_instance.position = closest_anchor.position

		if event.is_action_pressed("left_click"):
			_load_module(placing_module, module_width, _candidate_placement_node)
			placing_module_instance.queue_free()
			placing_module_instance = null
			_candidate_anchors = []

	# while NOT placing module
	else:
		if event.is_action_pressed("space"):
			if not current_cable:
				current_cable = CableScene.instantiate()
				# random color from list
				current_cable.col = GlobalColors.CABLE_COLORS[randi_range(0, GlobalColors.CABLE_COLORS.size()-1)]
				
				self.add_child(current_cable)
			else:
				current_cable.queue_free()
				current_cable = null



func _clear_placing_module() -> void:
	# clear existing placing module if it exists
	if placing_module_instance:
		placing_module_instance.queue_free()
		placing_module_instance = null
	_clear_candidate_anchors()

# creates an array of all available anchor points for a given module width
func _set_candidate_anchors(w: int) -> void:
	var candidates = []
	# find the last valid index
	var last_anchor_index = temp_unit_total - (w * ANCHOR_POINTS_PER_HP) + 2

	print("last_anchor_index", last_anchor_index)
	
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
	_candidate_anchors = candidates
		

func _load_module(module_scene: PackedScene, width: int, anchor) -> void:
	var module_instance = module_scene.instantiate()
	add_child(module_instance)
	module_instance.position = anchor.position
	loaded_modules.append(module_instance)

	_disable_anchors_by_index_and_hp(anchor.index, width)
	_clear_candidate_anchors()

	if module_instance is ModuleParent:
		module_instance.setup()
		
	_all_inputs.append(module_instance.inputs)
	_all_outputs.append(module_instance.outputs)
	
	for input_jack in module_instance.inputs:
		if input_jack is Jack:
			if input_jack.jack_clicked.is_connected(_on_jack_clicked):
				input_jack.jack_clicked.disconnect(_on_jack_clicked)
			input_jack.jack_clicked.connect(_on_jack_clicked)
			print(input_jack, " connections: ", input_jack.jack_clicked.get_connections().size())

			
	for output_jack in module_instance.outputs:
		if output_jack is Jack:
			if output_jack.jack_clicked.is_connected(_on_jack_clicked):
				output_jack.jack_clicked.disconnect(_on_jack_clicked)
			output_jack.jack_clicked.connect(_on_jack_clicked)
			print(output_jack, " connections: ", output_jack.jack_clicked.get_connections().size())


func _disable_anchors_by_index_and_hp(index: int, hp: int):
	var last_index = index + (hp * ANCHOR_POINTS_PER_HP) - 1
	for anchor in anchors:
		if anchor.index >= index and anchor.index <= last_index:
			anchor.available = false
			anchor.locked = true

func _clear_candidate_anchors() -> void:
	for a in anchors:
		a.candidate = false



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

func _on_jack_clicked(jack) -> void:
	var default_cable_length = 550

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
		if _candidate_jack_connection.global_position.distance_to(jack.global_position) > current_cable.total_length_in_pixels * GLOBAL_SCALE:
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
