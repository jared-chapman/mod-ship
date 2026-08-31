extends RigidBody2D

enum State {
	FOLLOW_MOUSE,
	HANG,
	INITIATE_HOVER,
	HOVER,
	INITIATE_LOCK,
	LOCK,
}

var _state: State
var target := Vector2.ZERO
var cable_data := {}


func _ready() -> void:
	$Plugged.visible = false;

func _process(_delta: float) -> void:
	pass


#region public setters
func set_cable_data(data):
	cable_data = data

func set_state_follow_mouse():
	_state = State.FOLLOW_MOUSE

func set_state_hang():
	_state = State.HANG

func set_state_initiate_hover(pos):
	# INITIATE_HOVER moves to HOVER when position is reached
	_state = State.INITIATE_HOVER
	target = pos

func set_state_initiate_hard_lock(pos):
	# INITIATE_LOCK moves to LOCK when position is reached
	_state = State.INITIATE_LOCK
	target = pos
#endregion


#region public getters
func is_following_mouse():
	return _state == State.FOLLOW_MOUSE

func is_hovering():
	return _state == State.INITIATE_HOVER || _state == State.HOVER

func is_locked():
	return _state == State.INITIATE_LOCK || _state == State.LOCK

func get_target():
	return target
#endregion


#region private setters
func _set_plugged(plugged: bool) -> void:
	$Plugged.visible = plugged
	$Unplugged.visible = not plugged
#endregion

func _integrate_forces(physics_state):
	var ps = physics_state
	var pos = ps.transform.origin

	match _state:
		State.FOLLOW_MOUSE:
			_handle_follow_mouse(pos, ps)
		State.HANG:
			_handle_hang(pos, ps)
		State.INITIATE_HOVER:
			_handle_initiate_hover(pos, ps)
		State.HOVER:
			_handle_hover(pos, ps)
		State.INITIATE_LOCK:
			_handle_initiate_lock(pos, ps)
		State.LOCK:
			_handle_lock(pos, ps)


#region state handlers
# Handles following mouse AND stretching if needed
func _handle_follow_mouse(_pos, ps) -> void:
	var mouse_pos = get_global_mouse_position()
	_move(ps.transform.origin, mouse_pos, ps, cable_data.follow_accelleration)
	

func _handle_hang(_pos, _ps) -> void:
	pass

func _handle_initiate_hover(pos, ps) -> void:
	if pos.distance_to(target) > 8:
		_move(pos, target, ps, cable_data.follow_accelleration)
	else:
		_state = State.HOVER

func _handle_hover(pos, ps) -> void:
	# TODO - build hover logic
	_hover_near_position(pos, target, 20, ps)

func _handle_initiate_lock(pos, ps) -> void:
	if pos.distance_to(target) > 20:
		_move(pos, target, ps, cable_data.snap_accelleration)
	else:
		_state = State.LOCK

func _handle_lock(_pos, ps) -> void:
	ps.linear_velocity = Vector2.ZERO
	var new_transform = ps.transform
	new_transform.origin = target

	ps.transform = new_transform
	ps.angular_velocity = 0

	_set_plugged(true)
#endregion


func _hover_near_position(pos, tar, _range, ps):
	# Placeholder - currently just moves to target still
	_move(pos, tar, ps, cable_data.follow_accelleration)
		

func _move(pos, tar, ps, accelleration) -> void:
	# use physics to move toward correct spot
	var desired_velocity = (tar - pos) * accelleration
	var end_velocity = desired_velocity.limit_length(cable_data.max_speed)

	ps.linear_velocity = end_velocity
	ps.angular_velocity = 0
