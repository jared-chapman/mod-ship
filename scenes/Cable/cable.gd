extends Node2D

@export var line: Line2D
@export var debug := true

@export var v2_test:= true

# the jacks that this cable is connected to
var output_jack: Node2D
var input_jack: Node2D

@onready var end_a := $EndA
@onready var end_b := $EndB
@onready var segments := [
	$Segment1,
	$Segment2,
	$Segment3,
	$Segment4,
	$Segment5,
	$Segment6,
	$Segment7,
	$Segment8,
	$Segment9,
	$Segment10,
]
@onready var joints := [
	$Joint_EndA_S1,
	$Joint_S1_S2,
	$Joint_S2_S3,
	$Joint_S3_S4,
	$Joint_S4_S5,
	$Joint_S5_S6,
	$Joint_S6_S7,
	$Joint_S7_S8,
	$Joint_S8_S9,
	$Joint_S9_S10,
	$Joint_S10_EndB,
]

@onready var cable_length = 550


# placing_a, placing_b, placed
var state: String = 'placing_a'


# when placing a cable, first end_a will be at the mouse and end_b will be dangling (figure this out)
# then when first end is placed, second end will be mouse
var _end_a_position: Vector2 = Vector2(0, 0)
var _end_b_position: Vector2 = Vector2(0, 0)

func _ready():
	line = $Line2D
	line.width = 2
	line.default_color = Color.RED

	end_a.follow_mouse = true
	end_b.follow_mouse = false

	end_a.next_segment = segments[0]
	end_b.next_segment = segments[-1]

	position = get_global_mouse_position()

	# can set cable length to distabce between a and b here

	print("cable instantiated")

func _process(_delta):

	if state == 'zero':
		pass
	if state == 'placing_a':
		pass
	if state == 'placing_b':
		pass

func place_a(pos):
	var DEBUG_JACK_OFFSET = Vector2(0, 0)
	_end_a_position = pos
	end_a.set_plugged(true)

	end_a.stay_at_position = _end_a_position
	end_a.follow_mouse = false
	end_b.follow_mouse = true

	state = 'placing_b'

func place_b(pos):
	var DEBUG_JACK_OFFSET = Vector2(0, 0)
	_end_b_position = pos + DEBUG_JACK_OFFSET
	end_b.set_plugged(true)

	end_b.stay_at_position = _end_b_position
	end_a.follow_mouse = false
	end_b.follow_mouse = false
	
	state = 'placed'
