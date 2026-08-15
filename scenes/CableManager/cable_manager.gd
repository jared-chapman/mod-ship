extends Node2D
@export var debug = true

@onready var active_cable
@onready var active_cables = []
@onready var modules = []
@onready var connections = []
@onready var racks = {}
@onready var viewing_rack
@onready var max_mouse_radius_in_pixels = 25
@onready var selection_method = "mouse"
@onready var focused_jack = null

@onready var cable_scene := preload("res://scenes/DynamicCable/DynamicCable.tscn")

const used_events = [
	'Primary',
	'Secondary',
	'Back',
	'Up',
	'Down',
	'Left',
	'Right',
	'Scroll_Up',
	'Scroll_Down',
	'Test_Cable'
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# FOR TESTING
	racks.test = {
		'jacks': [
			{
				"scene": %TestJack1,
				"is_input": false,
				"connected_to": null,
			},
			{
				"scene": %TestJack2,
				"is_input": true,
				"connected_to": null,
			},
			{
				"scene": %TestJack3,
				"is_input": true,
				"connected_to": null,
			},
			{
				"scene": %TestJack4,
				"is_input": true,
				"connected_to": null,
			},
			{
				"scene": %TestJack5,
				"is_input": true,
				"connected_to": null,
			},
		]
	}
	viewing_rack = 'test'


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if debug: queue_redraw()
	if selection_method == 'mouse':
		_focus_nearest_allowed_jack_to_mouse()




#region handle inputs
# TODO This should be moved to a main controller which should hit these functions
# when in module view
func _unhandled_input(event) -> void:
	# if debug: _log_keypress(event)
	if event.is_action_pressed('Primary'):     _handle_primary()
	if event.is_action_pressed('Secondary'):   _handle_secondary()
	if event.is_action_pressed('Up'):          _handle_direction('Up')
	if event.is_action_pressed('Down'):        _handle_direction('Down')
	if event.is_action_pressed('Left'):        _handle_direction('Left')
	if event.is_action_pressed('Right'):       _handle_direction('Right')
	if event.is_action_pressed('Scroll_Up'):   _handle_scroll('Up')
	if event.is_action_pressed('Scroll_Down'): _handle_scroll('Down')
	if event.is_action_pressed('Test_Cable'):  _handle_test_cable()

func _log_keypress(event) -> void:
	for e in used_events:
		if event.is_action_pressed(e):
			print(e, ' pressed')


func _handle_primary() -> void:
	_select_focused_jack()

func _handle_secondary() -> void:
	pass

func _handle_direction(dir) -> void:
	pass

func _handle_scroll(dir) -> void:
	pass

func _handle_test_cable() -> void:
	var cable = cable_scene.instantiate()
	add_child(cable)
	active_cable = {
		"scene": cable,
		"a": null,
		"b": null,
		"holding_a": true,
	}
	active_cables.append(cable)
	pass

#endregion

#region handle jack focus
func _draw():
	if debug && max_mouse_radius_in_pixels:
		var mouse_pos = get_global_mouse_position()
		draw_arc(mouse_pos, max_mouse_radius_in_pixels, 0, TAU, 64, Color.GREEN, 0.1, true)

func _find_nearest_allowed_jack_to_mouse(clear: bool = true):
	var jacksInViewingRack = racks[viewing_rack].jacks
	var closest_distance_to_mouse = max_mouse_radius_in_pixels
	var nearest_jack_to_mouse = null

	for jack in jacksInViewingRack:
		if clear:
			jack.scene.set_focused(false)
			focused_jack = null
		var distance_to_mouse: float = jack.scene.global_position.distance_to(get_global_mouse_position())

		var is_closest = distance_to_mouse < closest_distance_to_mouse
		var valid_in_out = \
		(active_cable == null) || \
		(!active_cable.a && !active_cable.b) || \
		(active_cable.a && active_cable.a.is_input != jack.is_input) || \
		(active_cable.b && active_cable.b.is_input != jack.is_input)

		if is_closest && valid_in_out:
			closest_distance_to_mouse = distance_to_mouse
			nearest_jack_to_mouse = jack

	if nearest_jack_to_mouse != null:
		return nearest_jack_to_mouse

	return null

func _focus_nearest_allowed_jack_to_mouse():
	var nearest = _find_nearest_allowed_jack_to_mouse()
	if nearest:
		nearest.scene.set_focused(true)
		focused_jack = nearest
	
#endregion

#region handle jack selection
func _select_focused_jack():
	# print({focused_jack: focused_jack, active_cable: active_cable})
	if !focused_jack: return
	if !active_cable: return
	print(focused_jack.scene)
	var holding_a = active_cable.holding_a

	# TODO make sure focused jack isn't already connected somehow
	
	# Connect holding_end to jack
	active_cable.scene.place(holding_a, focused_jack.scene.global_position)
	if holding_a:
		active_cable.a = focused_jack
	else:
		active_cable.b = focused_jack
	
	# Update jack and jacks array
	focused_jack.is_connected = true
	if active_cable.a && active_cable.b:
		print("oop")
		# set each jacks connected_to value to the other jack
		var jack_on_other_end_of_cable = active_cable.b if holding_a else active_cable.a
		focused_jack.connected_to = jack_on_other_end_of_cable
		jack_on_other_end_of_cable.connected_to = focused_jack

		# update values in arrays
		var indexes_of_connections = _get_indexes_of_jacks(focused_jack.scene, jack_on_other_end_of_cable.scene)
		var focused_index = indexes_of_connections[0]
		var connected_index = indexes_of_connections[1]
		
		racks[viewing_rack][focused_index] = focused_jack
		racks[viewing_rack][connected_index] = connected_index
		
		# if debug:
			# print('connected ', focused_jack.scene, ' to ', jack_on_other_end_of_cable.scene, ' : ', racks)

	# make cable inactive if other end is already connected
	# otherwise hold other end
	if active_cable.a && active_cable.b:
		active_cable = null
	else:
		active_cable.holding_a = !holding_a
		active_cable.scene.make_end_active(!holding_a)
			

func _get_indexes_of_jacks(scene1, scene2) -> Array:
	var index_a
	var index_b
	for i in range(racks[viewing_rack].size()):
		if racks[viewing_rack].jacks[i].scene.get_scene_file_path() == scene1.get_scene_file_path():
			index_a = i
		if racks[viewing_rack].jacks[i].scene.get_scene_file_path() == scene2.get_scene_file_path():
			index_b = i
	return [index_a, index_b]
