extends ModuleParent

var in_1
var in_2
var in_3

var switch_1
var switch_2
var switch_3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("radio ready")
	setup()
	in_1     = $Inputs/JackSmall
	in_2     = $Inputs/JackSmall2
	in_3     = $Inputs/JackSmall3
	switch_1 = $Inputs/SwitchSmall
	switch_2 = $Inputs/SwitchSmall2
	switch_3 = $Inputs/SwitchSmall3

	switch_1.set_input_name('switch_1')
	switch_2.input_name = 'switch_2'
	switch_3.input_name = 'switch_3'

	width_hp = 4

	switch_1.input_value_changed.connect(_flip_direction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(_delta: float) -> void:

func _flip_direction(_name, value):
	print('direction flipped - name: ', _name, ', value: ', value)

	
