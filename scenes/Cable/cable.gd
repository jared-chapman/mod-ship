extends Node2D

@export var line: Line2D
@export var debug := true

var output_jack: Node2D
var input_jack: Node2D

func _ready():
	line = $Line2D
	line.width = 2
	line.default_color = Color.RED

func _process(_delta):
	if output_jack and input_jack:
		var out_pos = to_local(output_jack.global_position)
		var in_pos = to_local(input_jack.global_position)
		line.points = [out_pos, in_pos]
