extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#ModuleManager.set_viewing_rack($RackSidebar)
	RackManager.add_rack($RackSidebar)
	RackManager.set_viewing_rack($RackSidebar)
	
	#var timer := Timer.new()
	#timer.wait_time = 2.0
	#timer.autostart = true
	#timer.timeout.connect(func(): Globals.debug = not Globals.debug; print('1'))
	#add_child(timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
