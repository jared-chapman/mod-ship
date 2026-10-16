extends Node
var racks = []
var viewing_rack


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func add_rack(rack):
	racks.append(rack)

func set_viewing_rack(rack):
	viewing_rack = rack
	
func get_viewing_rack():
	return viewing_rack

func begin_placing_module_in_active_rack(module):
	var valid_anchors = viewing_rack.get_candidate_anchors(module.width_hp)
	if len(valid_anchors) == 0:
		return
	viewing_rack.add_child(module)
	return valid_anchors
	
func place_module_in_active_rack(module, anchor_index):
	viewing_rack.disable_anchors_by_index_and_hp(anchor_index, module.width_hp)
	viewing_rack.add_module(module)

func get_current_rack_jacks():
	return viewing_rack.get_jacks()

	
	
	
	
	
	
	
	
