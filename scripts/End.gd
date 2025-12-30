extends RigidBody2D

@export var move_speed := 2200.0
@export var follow_strength := 20.0
@export var max_speed := 2200.0

# the total length of the cable
@export var max_length := 50.0

# the other end of this cable
var other_end
var parent_scale


var follow_mouse := true
var stay_at_position := Vector2.ZERO
var floating := false
# var target := Vector2.ZERO

var next_segment

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Plugged.visible = false;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# if stay_at_position and (global_position.distance_to(stay_at_position)) < 0.00001:
		# freeze = true
	pass


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



func set_plugged(plugged: bool) -> void:
	$Plugged.visible = plugged
	$Unplugged.visible = not plugged
