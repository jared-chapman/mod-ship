extends Jack


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)


func _on_area_2d_mouse_entered() -> void:
	set_is_over_jack(true)


func _on_area_2d_mouse_exited() -> void:
	set_is_over_jack(false)
