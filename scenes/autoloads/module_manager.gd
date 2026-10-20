extends Node

var ONE_HP_IN_PIXELS: int = 2

var placing_module_instance
var placing_module_current_anchor
var valid_anchor_point_locations

var anchor_offset = Vector2(-1, -0.97)

# state
enum State {
	READY_TO_PLACE_MODULE,
	PLACING_MODULE,
	IDLE
}
var _state: State


var module_scene_map = {
	"VCO": preload("res://scenes/RackView/Module/Modules/osc-2/osc_2.tscn"),
	"ATT": preload("res://scenes/RackView/Module/Modules/atten-2/atten_2.tscn"),
}

var action_key_map = {
	"PLACE": _place_module()
}


func _ready() -> void:
	_state = State.READY_TO_PLACE_MODULE


func _process(_delta: float) -> void:
	if _state == State.PLACING_MODULE:
		_handle_placing_module_state()
		
func get_placing_module():
	return placing_module_instance

func _unhandled_input(event):
	_handle_test_module_creation(event)
	

func _handle_test_module_creation(event):
	var module_key = ''
	
	if event.is_action_pressed('Up'):
		module_key = 'VCO'
	if event.is_action_pressed('Down'):
		module_key = 'ATT'
	
	if module_key:
		var module_scene = module_scene_map[module_key]
		_spawn_module(module_scene)
		return
		
	if Input.is_action_just_pressed("Primary") and _state == State.PLACING_MODULE:
		_place_module()
		return

func _spawn_module(module_scene) -> void:
	if _state != State.READY_TO_PLACE_MODULE or placing_module_instance:
		return
	
	placing_module_instance = module_scene.instantiate()
	valid_anchor_point_locations = RackManager.begin_placing_module_in_active_rack(placing_module_instance)
	
	if !valid_anchor_point_locations:
		# destroy modules instance and remove from scene
		placing_module_instance.queue_free()
		return
	
	_state = State.PLACING_MODULE
	
func _handle_placing_module_state():
	var viewport = get_viewport()
	if !viewport:
		return
		
	# find and snap to closest anchor
	# can't use get_global_mouse_positiong in an autoload, so we base it off the viewport
	var mouse_pos = viewport.get_canvas_transform().affine_inverse() * viewport.get_mouse_position()
	var mouse_off = Vector2(-(placing_module_instance.width_hp * ONE_HP_IN_PIXELS * 2), 0)
	var placement_pos = mouse_pos + mouse_off
	var closest_anchor = $TopLeftAnchor
	var closest_dist = INF
	for anchor in valid_anchor_point_locations:
		var dist = placement_pos.distance_to(anchor.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_anchor = anchor
			placing_module_current_anchor = anchor
	
	placing_module_instance.global_position = closest_anchor.global_position + anchor_offset
	
	
func _place_module():
	if !placing_module_instance:
		return

	if placing_module_instance is ModuleParent:
		placing_module_instance.setup()
		
	RackManager.place_module_in_active_rack(placing_module_instance, placing_module_current_anchor.index)
	
	placing_module_instance = null
	_state = State.READY_TO_PLACE_MODULE
	
