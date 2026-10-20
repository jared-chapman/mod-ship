extends Node2D
@export var debug = false

var active_cable
var max_mouse_radius_in_pixels = 25
var selection_method = "mouse"
var focused_jack = null

var cable_scene := preload("res://scenes/RackView/DynamicCable/DynamicCable.tscn")

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
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if debug: queue_redraw()
	if selection_method == 'mouse' && Engine.get_process_frames() % 5 == 0:
		_focus_nearest_allowed_jack_to_mouse()


#region debug functions

func _log_keypress(event) -> void:
	for e in used_events:
		if event.is_action_pressed(e):
			print(e, ' pressed')

func _draw():
	if debug && max_mouse_radius_in_pixels:
		var mouse_pos = get_global_mouse_position()
		draw_arc(mouse_pos, max_mouse_radius_in_pixels, 0, TAU, 64, Color.GREEN, 0.1, true)

#endregion


#region handle inputs
func _unhandled_input(event) -> void:
	# if debug: _log_keypress(event)
	if event.is_action_pressed('Primary'): _handle_primary()
	if event.is_action_pressed('Secondary'): _handle_secondary()
	if event.is_action_pressed('Up'): _handle_direction('Up')
	if event.is_action_pressed('Down'): _handle_direction('Down')
	if event.is_action_pressed('Left'): _handle_direction('Left')
	if event.is_action_pressed('Right'): _handle_direction('Right')
	if event.is_action_pressed('Scroll_Up'): _handle_scroll('Up')
	if event.is_action_pressed('Scroll_Down'): _handle_scroll('Down')
	if event.is_action_pressed('Test_Cable'): _create_cable()

func _handle_primary() -> void:
	_select_focused_jack()

func _handle_secondary() -> void:
	pass

func _handle_direction(_dir) -> void:
	pass

func _handle_scroll(_dir) -> void:
	pass

func _create_cable() -> void:
	if active_cable != null: return
	var cable = cable_scene.instantiate()
	add_child(cable)
	active_cable = {
		"instance": cable,
		"a": null,
		"b": null,
		"holding_a": true,
	}
	
func _destroy_active_cable() -> void:
	active_cable.queue_free()

#endregion


#region handle jack focus

func _find_nearest_allowed_jack_to_mouse(clear: bool = true):
	var jacksInViewingRack = RackManager.get_current_rack_jacks()
	var closest_distance_to_mouse = max_mouse_radius_in_pixels
	var nearest_jack_to_mouse = null
	if !jacksInViewingRack or len(jacksInViewingRack) == 0: return
	for jack in jacksInViewingRack:
		if not is_instance_valid(jack.instance): return
		if clear:
			jack.instance.set_focused(false)
			focused_jack = null
		var distance_to_mouse: float = jack.instance.global_position.distance_to(get_global_mouse_position())

		var is_closest = distance_to_mouse < closest_distance_to_mouse
		var valid_in_out = \
			((active_cable == null) || \
			(!active_cable.a && !active_cable.b) || \
			(active_cable.a && active_cable.a.is_input != jack.is_input) || \
			(active_cable.b && active_cable.b.is_input != jack.is_input)) && \
			!jack.connected_to

		if is_closest && valid_in_out:
			closest_distance_to_mouse = distance_to_mouse
			nearest_jack_to_mouse = jack

	if nearest_jack_to_mouse != null:
		return nearest_jack_to_mouse

	return null

func _focus_nearest_allowed_jack_to_mouse():
	var nearest = _find_nearest_allowed_jack_to_mouse()
	
	if nearest:
		nearest.instance.set_focused(true)
		focused_jack = nearest
		if active_cable:
			active_cable.instance.hover_at_position(active_cable.holding_a, focused_jack.instance.global_position)
	else:
		if active_cable:
			active_cable.instance.hold_end(active_cable.holding_a)
	
#endregion

#region handle jack selection
func _select_focused_jack():
	if !focused_jack or !active_cable: return
	var holding_a = active_cable.holding_a

	# TODO make sure focused jack isn't already connected by checking moduleManager?
	# Connect holding_end to jack
	active_cable.instance.place(holding_a, focused_jack.instance.global_position)
	if holding_a:
		active_cable.a = focused_jack
	else:
		active_cable.b = focused_jack
	
	# if both ends connected, trigger connection establishment
	# otherwise, start holding other end of cable
	focused_jack.is_connected = true
	if active_cable.a && active_cable.b:
		_establish_connection(active_cable.a.instance, active_cable.b.instance)
	else:
		active_cable.holding_a = !holding_a


func _establish_connection(instance_a, instance_b):
	instance_a.establish_connection(instance_b)
	instance_b.establish_connection(instance_a)
	
	active_cable = null

	
