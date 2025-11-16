extends Knob

@export var _name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	var sprite_node = $LargeSprite
	if sprite_node:
		set_angle_sprites(sprite_node.get_children())
		set_value(value)
		set_knob_name(_name)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	
func set_knob_name(n: String):
	input_name = n


func _on_area_2d_mouse_entered() -> void:
	set_is_over_knob(true)



func _on_area_2d_mouse_exited() -> void:
	set_is_over_knob(false)
