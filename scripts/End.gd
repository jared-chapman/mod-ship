extends RigidBody2D

var follow_mouse := true
var stay_at_position: Vector2 = Vector2.ZERO

var next_segment

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Plugged.visible = false;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if stay_at_position and (global_position.distance_to(stay_at_position)) < 0.1:
		freeze = true
	pass


func _integrate_forces(state):
	if follow_mouse:
		state.transform.origin = get_global_mouse_position()
		state.linear_velocity = Vector2.ZERO;
		state.angular_velocity = 0

	elif stay_at_position != Vector2.ZERO:
		state.transform.origin = stay_at_position
		state.linear_velocity = Vector2.ZERO;
		state.angular_velocity = 0;


func set_plugged(plugged: bool) -> void:
	$Plugged.visible = plugged
	$Unplugged.visible = not plugged
