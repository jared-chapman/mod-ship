extends Control
class_name SidePanel

@onready var rack_name_label = $VBoxContainer/RackName
@onready var module_list = $VBoxContainer/ModuleList

func show_rack(rack: Rack):
	visible = true
	rack_name_label.text = "Rack: " + rack.name
	for c in module_list.get_children():
		c.queue_free()
	for m in rack.loaded_modules:
		var label = Label.new()
		label.text = m.module_name
		module_list.add_child(label)

func hide_rack():
	visible = false
