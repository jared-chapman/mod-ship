extends RigidBody2D

@export var move_speed := 2200.0
@export var follow_strength := 20.0
@export var max_speed := 2200.0

# the total length of the cable
@export var max_length := 145.0

# the other end of this cable
var other_end
var parent_scale

# inherited on instantion from parent
var parent_cable
var number_of_segments
var segments
var joints

var base_segment_length
var follow_mouse := true
var stay_at_position := Vector2.ZERO
var floating := false
# var target := Vector2.ZEROma


var next_segment

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Plugged.visible = false;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# before change to update length
func _integrate_forces(state):

	var target := Vector2.ZERO
	var origin = state.transform.origin

	if follow_mouse:
		var mouse_pos = get_global_mouse_position()
		if not other_end:
			target = mouse_pos
			floating = false
		else:
			var other_pos = other_end.global_position
			var distance_between_mouse_and_origin = other_pos.distance_to(mouse_pos)
			print('distance to other end: ', distance_between_mouse_and_origin)

			var length_offset = 60
			var max_allowed_length = max_length * parent_scale - length_offset

			if distance_between_mouse_and_origin > max_allowed_length:
				var direction = (mouse_pos - other_pos).normalized()
				target = other_pos + direction * max_allowed_length
				floating = true
			else:
				target = mouse_pos
				floating = false

		# use physics to place in correct spot
		var desired_velocity = (target - state.transform.origin) * follow_strength
		state.linear_velocity = desired_velocity.limit_length(max_speed)
		state.angular_velocity = 0

	elif stay_at_position != Vector2.ZERO:
		# force to lock to position
		target = stay_at_position
		state.transform.origin = target
		state.linear_velocity =Vector2.ZERO

	else:
		return


# func _integrate_forces(state):
# 	var origin = state.transform.origin
# 	var target := Vector2.ZERO

# 	if follow_mouse:
# 		var mouse_pos = get_global_mouse_position()

# 		# Determine the target based on whether the other end is attached
# 		if not other_end:
# 			target = mouse_pos
# 			floating = false
# 		else:
# 			var other_pos = other_end.global_position
# 			var distance_between_ends = other_pos.distance_to(mouse_pos)

# 			var length_offset = 0
# 			var max_allowed_length = max_length - length_offset
# 			var total_max_stretch = max_length # absolute max length

# 			if distance_between_ends > max_allowed_length:
# 				# direction from the fixed end to the mouse
# 				var direction = (mouse_pos - other_pos).normalized()
# 				target = other_pos + direction * max_allowed_length
# 				floating = true
# 			else:
# 				target = mouse_pos
# 				floating = false

# 			# --- Stretch segments if beyond nominal length ---
# 			var nominal_length = base_segment_length * number_of_segments * parent_scale
# 			if distance_between_ends > nominal_length:
# 				print('stretching to ', distance_between_ends)
# 				var extra_length = min(distance_between_ends - nominal_length, total_max_stretch - nominal_length)
# 				var extra_per_segment = extra_length / number_of_segments * parent_scale
# 				print('adding ', extra_per_segment, ' length')
# 				for s in segments:
# 					var sprite = s.get_node("Sprite2D")
# 					var original_height = sprite.get_rect().size.y
# 					var target_length = base_segment_length + extra_per_segment * parent_scale
# 					var target_scale = target_length / original_height * parent_scale

# 					# smooth scaling
# 					s.scale.y = lerp(s.scale.y, target_scale, 0.05)

# 					# update joint position if joint is independent
# 					var joint = joints[s] if joints.has(s) else null
# 					if joint:
# 						joint.position = s.global_position + Vector2(0, s.scale.y * original_height * parent_scale)

# 		# Physics: move towards target
# 		var desired_velocity = (target - origin) * follow_strength
# 		state.linear_velocity = desired_velocity.limit_length(max_speed)
# 		state.angular_velocity = 0

# 	elif stay_at_position != Vector2.ZERO:
# 		# Lock to a position
# 		target = stay_at_position
# 		state.transform.origin = target
# 		state.linear_velocity = Vector2.ZERO

# 	else:
# 		return




func set_plugged(plugged: bool) -> void:
	$Plugged.visible = plugged
	$Unplugged.visible = not plugged
