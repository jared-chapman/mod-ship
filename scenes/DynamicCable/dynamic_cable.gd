extends Node2D

enum State {
	PLACING_INITIAL,
	PLACING_SECONDARY,
	PLACED
}

var _state: State

# physical cable attributes
var NUMBER_OF_SEGMENTS: int = 5
var INITIAL_LENGTH_IN_PIXELS: int = 20
var TOTAL_MASS: float = 2.0
var STRETCH_SOFTNESS: float = 15.0
var col := Color(1, 1, 1, 1)


var segments = []
var joints = []


@onready var end_a := $EndA
@onready var end_b := $EndB
@onready var segment_node = $Segment
@onready var joint_node = $Joint
@onready var cable_data = {
		'follow_accelleration': 6.0,
		'snap_accelleration': 300.0,
		'max_speed': 400.0,
		'end_a': end_a,
		'end_b': end_b,
		'other_end': '',
	}


func _ready() -> void:
	print('creating cable of length', INITIAL_LENGTH_IN_PIXELS)
	_build_cable()
	_state = State.PLACING_INITIAL


func _process(_delta: float) -> void:
	_update_end_rotations()
	_draw_cable()


#region public state setters
func set_state_placing_initial():
	_state = State.PLACING_INITIAL
	_set_allow_stretch(false)
	pass

func set_state_placing_secondary():
	_state = State.PLACING_SECONDARY
	_set_allow_stretch(true)
	pass

func set_state_placed():
	_state = State.PLACED
	pass
#endregion

func _draw_cable():
	if segments.size() == 0 or not end_a or not end_b:
		return
	var points = [end_a.position]
	for s in segments:
		points.append(s.position)
	points.append(end_b.position)
	$Line2D.points = catmull_rom_spline(points, 500)

func _set_allow_stretch(allow) -> void:
	print('allow stretch ', allow)
	if len(joints) == 0:
		return
	
	for joint in joints:
		joint.softness = STRETCH_SOFTNESS if allow else 0.0

func _build_cable():
	var segment_length_in_pixels: int = int(INITIAL_LENGTH_IN_PIXELS / (NUMBER_OF_SEGMENTS * 1.0))
	# modify segment so copies inherit scale, etc.

	# set mass of each segment to it's portion (including both ends)
	segment_node.mass = TOTAL_MASS / NUMBER_OF_SEGMENTS

	# offset by mouse position
	var mouse_pos = get_global_mouse_position()

	# what the next joint will connect to
	var prev_segment = end_a
	var prev_v_position = mouse_pos.y - (segment_length_in_pixels)

	# place EndA
	end_a.position = mouse_pos

	# place rest of segments and joints
	for s in range(NUMBER_OF_SEGMENTS):
		var seg_copy = segment_node.duplicate()
		var joint_copy   = joint_node.duplicate()

		# place segment
		var seg_v_pos = prev_v_position + segment_length_in_pixels
		seg_copy.position = Vector2(mouse_pos.x, seg_v_pos)
		prev_v_position = seg_v_pos

		# place joint
		joint_copy.position = Vector2(mouse_pos.x, seg_v_pos)
		
		add_child(seg_copy)
		add_child(joint_copy)
		segments.append(seg_copy)
		joints.append(joint_copy)

		# connect joint
		joint_copy.node_a = prev_segment.get_path()
		joint_copy.node_b = seg_copy.get_path()

		# set current segment to previous, so next joint connects to it
		prev_segment = seg_copy

	# place EndB after last segment
	var end_v_position = prev_v_position + segment_length_in_pixels
	print('prev_v_position', prev_v_position)
	end_b.position = Vector2(mouse_pos.x, end_v_position)

	# create one more joint to attach EndB to last segment
	var last_joint = joint_node.duplicate()
	last_joint.position = Vector2(mouse_pos.x, end_v_position)
	add_child(last_joint)
	joints.append(last_joint)
	last_joint.node_a = prev_segment.get_path()
	last_joint.node_b = end_b.get_path()


	# give the ends some information about the cable to access it more easily
	var cable_data_a = cable_data.duplicate(true)
	var cable_data_b = cable_data.duplicate(true)
	cable_data_a.other_end = end_b
	cable_data_b.other_end = end_a
	end_a.set_cable_data(cable_data_a)
	end_b.set_cable_data(cable_data_b)

	# set initial end states
	end_a.set_state_follow_mouse()
	end_b.set_state_hang()

	_update_colors(col)


func _update_colors(c = col) -> void:
	$EndA.get_node("Unplugged").modulate = c
	$EndA.get_node("Plugged").modulate = c
	$EndB.get_node("Unplugged").modulate = c
	$EndB.get_node("Plugged").modulate = c
	$Line2D.modulate = c


func _update_end_rotations() -> void:
	if segments.size() == 0 or not end_a or not end_b:
		return

	# EndA faces first segment
	var dir_a = segments[0].global_transform.y.angle()
	$EndA.rotation = dir_a - (PI/2)

	# # EndB faces last segment
	var dir_b = segments[-1].global_transform.y.angle()
	$EndB.rotation = dir_b - (PI/2)


# snaps end to pos without connecting it
func hover_at_position(is_a, pos):
	var end = end_a if is_a else end_b
	if !end.is_hovering() || pos != end.get_target():
		end.set_state_initiate_hover(pos)


# causes end to follow mouse
func hold_end(is_a):
	var end = end_a if is_a else end_b
	if !end.is_following_mouse():
		end.set_state_follow_mouse()


# moves to position and creates connection
func place(is_a, pos):
	var end = end_a if is_a else end_b
	end.set_state_initiate_hard_lock(pos)

	if _state == State.PLACING_INITIAL:
		set_state_placing_secondary()

	if _state == State.PLACING_SECONDARY:
		set_state_placed()


# https://gist.github.com/JoelBesada/8cb4508dfbcd4e23f639476fd89b1952
func catmull_rom_spline(
	_points: Array, resolution: int = 5, extrapolate_end_points = true
	) -> PackedVector2Array:
	var points = _points.duplicate()
	if extrapolate_end_points:
		points.insert(0, points[0] - (points[1] - points[0]))
		points.append(points[-1] + (points[-1] - points[-2]))

	var smooth_points := PackedVector2Array()
	if points.size() < 4:
		return PackedVector2Array(points)

	for i in range(1, points.size() - 2):
		var p0 = points[i - 1]
		var p1 = points[i]
		var p2 = points[i + 1]
		var p3 = points[i + 2]

		for t in range(0, resolution):
			var tt = t / float(resolution)
			var tt2 = tt * tt
			var tt3 = tt2 * tt

			var q = (
				0.5
				* (
				(2.0 * p1)
				+ (-p0 + p2) * tt
				+ (2.0 * p0 - 5.0 * p1 + 4 * p2 - p3) * tt2
				+ (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * tt3
				)
			)

			smooth_points.append(q)

	return smooth_points
