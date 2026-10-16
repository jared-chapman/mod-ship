extends Node2D
@export var frozen = true

var ONE_HP_IN_PIXELS: int = 2
var ANCHOR_POINTS_PER_HP: int = 4
var temp_unit_total = 79

var anchor_point = preload("res://scripts/anchor_point.gd")
var anchors = []

var modules = []
var jacks = []

signal mouse_entered_rack(rack)
signal mouse_exited_rack(rack)

func _ready() -> void:
	# spawn all possible anchor points
	$TopLeftAnchor.available = true
	$TopLeftAnchor.index = 0
	for i in temp_unit_total:
		var anchor = anchor_point.new()
		anchor.name = "%s%d" % [(i + 1)]
		anchor.position = Vector2($TopLeftAnchor.position.x + (ONE_HP_IN_PIXELS * i + 1), $TopLeftAnchor.position.y)
		anchor.available = true
		anchor.index = i + 1
		anchors.append(anchor)
		add_child(anchor)

	$Area2D.mouse_entered.connect(_on_mouse_entered_rack)
	$Area2D.mouse_exited.connect(_on_mouse_exited_rack)

## Creates an array of all available anchor points for a given module width
func get_candidate_anchors(w: int) -> Array:
	var candidates = []
	var last_anchor_index = temp_unit_total - (w * ANCHOR_POINTS_PER_HP) + 2
	
	for anchor in anchors:
		if anchor.index > last_anchor_index:
			continue
			
		var valid = true
		var sub_anchors = anchors.slice(anchor.index - 1, anchor.index + (w * ANCHOR_POINTS_PER_HP) - 1)
		for a in sub_anchors:
			if not a.available: 
				valid = false
				anchor.candidate = false
		
		if valid:
			anchor.candidate = true
			candidates.append(anchor)
	return candidates

## Disables anchor points that would be covered by a module
func disable_anchors_by_index_and_hp(index: int, hp: int):
	var last_index = index + (hp * ANCHOR_POINTS_PER_HP) - 1
	for anchor in anchors:
		if anchor.index >= index and anchor.index <= last_index:
			anchor.available = false
			anchor.locked = true

## Adds a module to the modules array and its in/outputs to those arrays
#  The rack doesn't care about module positions once they've been set
func add_module(module):
	
	# get all jacks for this module and reshape a bit
	var raw_jacks = module.get_connections()
	var _jacks = \
		raw_jacks.inputs \
			.map(func(c): return {
				'is_input': true,
				'connected_to': null,
				'instance': c,
				'scene': c.scene_file_path
			}) + \
		raw_jacks.outputs \
			.map(func(c): return {
				'is_input': false,
				'connected_to': null,
				'instance': c,
				'scene': c.scene_file_path

			})
	modules.append(module)
	jacks = jacks + _jacks
	
func get_jacks():
	return jacks;

## Freezes or unfreezes rack to hide and stop physics
func set_frozen(val):
	frozen = val
	self.visible = !val

func _on_mouse_entered_rack():
	mouse_entered_rack.emit(self)

func _on_mouse_exited_rack():
	mouse_exited_rack.emit()
