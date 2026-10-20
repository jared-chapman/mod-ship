extends Knob

func _ready() -> void:
	await get_tree().process_frame
	var sprite_node = $SmallSprite
	if sprite_node:
		set_angle_sprites(sprite_node.get_children())
		set_value(value)
	
func _process(delta: float) -> void:
	super._process(delta)


func _on_area_2d_mouse_entered() -> void:
	set_is_over_knob(true)

func _on_area_2d_mouse_exited() -> void:
	set_is_over_knob(false)
