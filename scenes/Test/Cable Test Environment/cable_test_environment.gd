extends Node2D

var test_jacks_rack = {
		'rack_name': 'test_rack_1',
		'jacks': [
			{
				"scene": %TestJack1,
				"is_input": false,
				"connected_to": null,
			},
			{
				"scene": %TestJack2,
				"is_input": true,
				"connected_to": null,
			},
			{
				"scene": %TestJack3,
				"is_input": false,
				"connected_to": null,
			},
			{
				"scene": %TestJack4,
				"is_input": true,
				"connected_to": null,
			},
			{
				"scene": %TestJack5,
				"is_input": false,
				"connected_to": null,
			},
			{
				"scene": %TestJack6,
				"is_input": true,
				"connected_to": null,
			},
			{
				"scene": %TestJack7,
				"is_input": false,
				"connected_to": null,
			},
			{
				"scene": %TestJack8,
				"is_input": true,
				"connected_to": null,
			},
		]
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('ready')
	_add_test_rack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _add_test_rack():
	print('adding test rack')
	CableManager.add_rack(test_jacks_rack)
