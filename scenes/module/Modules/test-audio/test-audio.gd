extends ModuleParent

var sig_in


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	sig_in = inputs[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
