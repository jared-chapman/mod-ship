extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#ModuleManager.set_viewing_rack($RackSidebar)
	RackManager.add_rack($RackSidebar)
	print('setting viewing rack')
	RackManager.set_viewing_rack($RackSidebar)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
