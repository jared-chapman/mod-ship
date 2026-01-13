extends Node2D

@export var number_of_segments: int = 1000;
@export var total_length_in_pixels: int = 140;
@export var segment_length_in_pixels: int = 50;
@export var max_length_in_pixels: int = 400;
@export var segment_goal_mass: float = 5.0;
@export var col := Color(1, 1, 1, 1)

const GLOBAL_SCALE = 3
var segments = []
var joints = []

var state: String = 'placing_a'

@onready var end_a := $EndA
@onready var end_b := $EndB
# when placing a cable, first end_a will be at the mouse and end_b will be dangling (figure this out)
# then when first end is placed, second end will be mouse
var _end_a_position: Vector2 = Vector2(0, 0)
var _end_b_position: Vector2 = Vector2(0, 0)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var segment_node = $Segment
	var joint_node = $Joint

	_build_cable(segment_node, joint_node, end_a, end_b)

	end_a.parent_cable = self
	end_b.parent_cable = self

	end_a.base_segment_length = segment_length_in_pixels
	end_b.base_segment_length = segment_length_in_pixels

	end_a.number_of_segments = number_of_segments
	end_b.number_of_segments = number_of_segments

	end_a.segments = segments
	end_b.segments = segments

	end_a.joints = joints
	end_b.joints = joints

	end_a.follow_mouse = true
	end_b.follow_mouse = false

	# end_a.max_length = max_length_in_pixels
	# end_b.max_length = max_length_in_pixels
	end_a.parent_scale = GLOBAL_SCALE
	end_b.parent_scale = GLOBAL_SCALE

	# end_a.other_end = end_b
	end_b.other_end = end_a


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_update_end_rotations()

	# draw line through segments
	var points = [$EndA.position]
	for s in segments:
		points.append(s.position)
	points.append($EndB.position)
	$Line2D.points = catmull_rom_spline(points, 10, false)




func _build_cable(segment, joint, endA, endB):

	# modify segment so copies inherit scale, etc.

	# set scale
	var starting_height = segment.get_node("Sprite2D").get_rect().size.y
	var _scale = segment_length_in_pixels / starting_height
	segment.scale = Vector2(1, _scale)
	segment.mass = segment_goal_mass / number_of_segments
	print({
		'segment_length_in_pixels': segment_length_in_pixels,
		'starting_height': starting_height,
		'_scale': _scale,
	})

	# offset by mouse position
	var mouse_pos = get_global_mouse_position()

	# what the next joint will connect to
	var prev_segment = endA
	var prev_v_position = mouse_pos.y - (segment_length_in_pixels * GLOBAL_SCALE)

	# place EndA
	$EndA.position = mouse_pos

	for s in range(number_of_segments):
		var seg_copy = segment.duplicate()
		var joint_copy = joint.duplicate()

		
		# place segment
		var seg_v_pos = prev_v_position + (segment_length_in_pixels * GLOBAL_SCALE)
		seg_copy.position = Vector2(mouse_pos.x, seg_v_pos)
		prev_v_position = seg_v_pos

		# place joint
		# var joint_v_pos = s * (segment_length_in_pixels * GLOBAL_SCALE) - (nudge * s)
		# joint_copy.position = Vector2(0, joint_v_pos)
		joint_copy.position = Vector2(mouse_pos.x, seg_v_pos)
		
		add_child(seg_copy)
		add_child(joint_copy)
		# segments.append(seg_v_pos)
		segments.append(seg_copy)
		joints.append(joint_copy)

		# connect joint
		joint_copy.node_a = prev_segment.get_path()
		joint_copy.node_b = seg_copy.get_path()

		# set current segment to previous, so next joint connects to it
		prev_segment = seg_copy

	# place EndB after last segment
	var end_v_position = prev_v_position
	$EndB.position = Vector2(mouse_pos.x, end_v_position)

	# create one more joint to attach EndB to last segment
	var last_joint = joint.duplicate()
	last_joint.position = Vector2(mouse_pos.x, end_v_position)
	add_child(last_joint)
	last_joint.node_a = prev_segment.get_path()
	last_joint.node_b = $EndB.get_path()

	# delete initial segment and joint
	$Segment.queue_free()
	$Joint.queue_free()

	# $EndA.get_node("Unplugged").modulate = col
	# $EndA.get_node("Plugged").modulate = col
	# $EndB.get_node("Unplugged").modulate = col
	# $EndB.get_node("Plugged").modulate = col
	# $Line2D.modulate = col
	_update_colors(col)


func _update_colors(c = col) -> void:
	$EndA.get_node("Unplugged").modulate = c
	$EndA.get_node("Plugged").modulate = c
	$EndB.get_node("Unplugged").modulate = c
	$EndB.get_node("Plugged").modulate = c
	$Line2D.modulate = c


func _update_end_rotations() -> void:
	if segments.size() == 0:
		return

	# EndA faces first segment
	var dir_a = segments[0].global_transform.y.angle()
	# if dir_a.length_squared() > 0.0001:
	$EndA.rotation = dir_a - (PI/2)
	# $EndA.position = segments[0].position

	# # EndB faces last segment
	var dir_b = segments[-2].global_transform.y.angle()
	$EndB.rotation = dir_b - (PI/2)
	# $EndB.position = segments[-1].position

func place_a(pos):
	var DEBUG_JACK_OFFSET = Vector2(0, 0)
	_end_a_position = pos
	end_a.set_plugged(true)

	end_a.stay_at_position = _end_a_position
	end_a.follow_mouse = false
	end_b.follow_mouse = true

	state = 'placing_b'

func place_b(pos):
	var DEBUG_JACK_OFFSET = Vector2(0, 0)
	_end_b_position = pos + DEBUG_JACK_OFFSET
	end_b.set_plugged(true)

	end_b.stay_at_position = _end_b_position
	end_a.follow_mouse = false
	end_b.follow_mouse = false
	
	state = 'placed'

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
