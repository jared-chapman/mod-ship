extends Node2D

class_name Rack

@export var capacity := 1
var loaded_modules = []

signal player_entered(rack)
signal player_exited(rack)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("rack")
	$InteractArea.body_entered.connect(_on_body_entered)
	$InteractArea.body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func has_capacity() -> bool:
	return loaded_modules.size() < capacity
	
func load_module(m) -> void:
	if not has_capacity(): return
	add_child(m)
	m.position = Vector2(0, -24)
	loaded_modules.append(m)
	
func clear_all_modules() -> void:
	for m in loaded_modules:
		if is_instance_valid(m):
			m.queue_free()
	loaded_modules.clear()
		
func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("player_entered", self);

func _on_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("player_exited", self);
