extends Node2D

var loaded_modules = []
@export var default_test_module: PackedScene
var fill = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var placing_module: PackedScene = null
var placing_module_instance
@export var test_placing_module: PackedScene
@export var test_placing_module_2: PackedScene

var hp_width: int = 48
var single_units_per_hp: int = 4
var single_unit_width: int = int(hp_width / single_units_per_hp)
var temp_unit_total = 79
var test_module_width = 4

var _all_inputs := []
var _all_outputs := []

var _candidate_placement_node
var _candidate_jack_connection = null

var anchor_point = preload("res://scripts/anchor_point.gd")
var anchors = []
var _candidate_anchors = []

# For cable visualization
var CableScene := preload("res://scenes/Cable/cable.tscn")
var cables: Array = []


func _ready() -> void:
	# spawn all possible anchor points
	anchors.append($TopLeftAnchor)
	$TopLeftAnchor.available = true
	$TopLeftAnchor.index = 0
	for i in temp_unit_total:
		var anchor = anchor_point.new()
		anchor.name = "anchor_%d" % (i + 1)
		anchor.position = Vector2($TopLeftAnchor.position.x + (single_unit_width * i + 1), $TopLeftAnchor.position.y)
		anchor.available = true
		anchor.index = i + 1
		anchors.append(anchor)
		add_child(anchor)


func _process(_delta: float) -> void:
	pass


func _input(event):
	if event.is_action_pressed("x"):
		placing_module = test_placing_module
		if placing_module:
			var instance = placing_module.instantiate()
			instance.width_hp = 4
			add_child(instance)
			placing_module_instance = instance
			
	if event.is_action_pressed("c"):
		placing_module = test_placing_module_2
		if placing_module:
			var instance = placing_module.instantiate()
			instance.width_hp = 4
			add_child(instance)
			placing_module_instance = instance

	# while placing module
	if placing_module_instance:
		if not _candidate_anchors:
			_set_candidate_anchors(test_module_width)
		
		# mouse position should be center of module
		var mouse_pos = get_global_mouse_position()
		var mouse_off = Vector2(-(placing_module_instance.width_hp * single_unit_width * 2), 0)
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
			_load_module(placing_module, test_module_width, _candidate_placement_node)
			placing_module_instance.queue_free()
			placing_module_instance = null
			_candidate_anchors = []



# creates an array of all available anchor points for a given module width
func _set_candidate_anchors(w: int) -> void:
	var candidates = []
	# find the last valid index
	var last_anchor_index = temp_unit_total - (w * single_units_per_hp) + 2
	while anchors[last_anchor_index].locked and last_anchor_index > 0:
		last_anchor_index = last_anchor_index - 1
	print("last_anchor_index", last_anchor_index)
	
	for anchor in anchors:
		if anchor.index > last_anchor_index:
			continue
			
		var valid = true
		var sub_anchors = anchors.slice(anchor.index, anchor.index + (w * single_units_per_hp) - 1)
		for a in sub_anchors:
			if not a.available: 
				valid = false
				anchor.available = false
		
		if valid:
			candidates.append(anchor)
	_candidate_anchors = candidates
		

func _load_module(module_scene: PackedScene, width: int, anchor) -> void:
	var module_instance = module_scene.instantiate()
	add_child(module_instance)
	module_instance.position = anchor.position
	loaded_modules.append(module_instance)

	_disable_anchors_by_index_and_hp(anchor.index, width)

	# 👇 Make it compatible with ModuleParent
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
	var last_index = index + (hp * single_units_per_hp) - 1
	for anchor in anchors:
		if anchor.index >= index and anchor.index <= last_index:
			anchor.available = false
			anchor.locked = true


func _create_test_connection(module_instance: ModuleParent):
	if module_instance.outputs.is_empty() or module_instance.inputs.is_empty():
		return
	
	var out_jack = module_instance.outputs[3]  # first output
	var in_jack = module_instance.inputs[3]    # first input
	_create_connection(in_jack, out_jack)


func _create_connection(in_jack, out_jack):

	# Draw cable
	var cable = CableScene.instantiate()
	cable.output_jack = out_jack
	cable.input_jack = in_jack
	add_child(cable)
	cables.append(cable)

	# Forward output values to input
	out_jack.output_value_changed.connect(func(_n, val):
		in_jack.set_value(val)
	)

	# Initialize immediately
	in_jack.set_value(out_jack.value)
	in_jack.connected = true
	out_jack.connected = true

func _on_jack_clicked(jack) -> void:
	if _candidate_jack_connection == null:
		print("setting candidate to ", jack, " - in: ", jack.is_input)
		_candidate_jack_connection = jack
		return
		
	else:
		print("candidate is input: ", _candidate_jack_connection.is_input)
		print("selected is input: ", jack.is_input)

		
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
		print("in - ", _in, " out - ", _out)
		if not _in and _out:
			print("oopsie")
			_candidate_jack_connection = null
			return
		_create_connection(_in, _out)
		_candidate_jack_connection = null
