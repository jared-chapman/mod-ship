extends RigidBody2D

@export var move_speed := 1200.0
@export var follow_strength := 35.0
@export var max_speed := 3000.0

# the total length of the cable
@export var max_length := 50.0

var follow_mouse := true
var stay_at_position := Vector2.ZERO
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
		var distance_to_mouse = mouse_pos - origin
		if distance_to_mouse.length() > max_length:
			target = origin + distance_to_mouse.normalized() * max_length
		else:
			target = mouse_pos

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

	

	# var target := Vector2.ZERO

	# if follow_mouse:
	# 	target = get_global_mouse_position()
	# elif stay_at_position != Vector2.ZERO:
	# 	target = stay_at_position
	# else: return

	# var to_target = target - state.transform.origin
	# var max_step = move_speed * state.step

	# if to_target.length() <= max_step:
	# 	state.transform.origin = target
	# 	state.linear_velocity =Vector2.ZERO
	# else:
	# 	state.transform.origin += to_target.normalized() * max_step
	# 	state.linear_velocity = Vector2.ZERO

	# state.angular_velocity = 0


	# 	state.transform.origin = get_global_mouse_position()
	# 	state.linear_velocity = Vector2.ZERO;
	# 	state.angular_velocity = 0

	# elif stay_at_position != Vector2.ZERO:
	# 	state.transform.origin = stay_at_position
	# 	state.linear_velocity = Vector2.ZERO;
	# 	state.angular_velocity = 0;


func set_plugged(plugged: bool) -> void:
	$Plugged.visible = plugged
	$Unplugged.visible = not plugged
