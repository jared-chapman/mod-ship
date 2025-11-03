extends Node2D

@onready var room_container = $RoomContainer
@onready var player = $Player
@onready var ui = $CanvasLayer/SidePanel
@export var room_scene: PackedScene
@export var module_scene: PackedScene

var current_rack: Rack = null

const MAX_RACK_DISTANCE := 64;



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create one room
	var room = room_scene.instantiate()
	room_container.add_child(room)
	room.position = Vector2(0, 0)

	# Connect the player's signals
	player.request_place_module.connect(_on_request_place_module.bind(room))
	player.request_clear_rack.connect(_on_request_clear_rack.bind(room))
	
	# Connect to rack signals
	for r in room.get_children():
		if r is Rack:
			r.player_entered.connect(_on_rack_player_entered)
			r.player_exited.connect(_on_rack_player_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_text_indent") and current_rack:
		ui.show_rack(current_rack)

func _on_request_place_module(pos: Vector2, room):
	var rack = _get_closest_rack(pos, room)
	if rack:
		var in_range = rack.global_position.distance_to(pos) <= MAX_RACK_DISTANCE
		var has_capacity = rack.has_capacity()
		if in_range and has_capacity:
			print('loading module')
			var module: Module = module_scene.instantiate()
			rack.load_module(module)
		else:
			if not in_range:
				print('rack out of range')
			if not has_capacity:
				print('rack is full')
	else:
		print('no rack')
		
func _on_request_clear_rack(pos: Vector2, room):
	var rack = _get_closest_rack(pos, room)
	if rack:
		var in_range = rack.global_position.distance_to(pos) <= MAX_RACK_DISTANCE
		if in_range:
			print('clearing rack')
			rack.clear_all_modules()
		else:
			if not in_range:
				print('rack out of range')
	else:
		print('no rack')
	
func _get_closest_rack(pos: Vector2, room: Node) -> Rack:
	var best: Rack = null
	var best_dist := INF

	for r in get_tree().get_nodes_in_group("rack"):
		if room.is_ancestor_of(r):                      # ensure the rack belongs to this room
			var d := (r as Node2D).global_position.distance_to(pos)
			if d < best_dist:
				best_dist = d
				best = r
	return best

func _on_rack_player_entered(rack: Rack):
	current_rack = rack
	print("player near rack: ", rack.name)
	
func _on_rack_player_exited(rack: Rack):
	current_rack = null
	print("player not close to any rack")
