extends Resource
class_name GlobalColors


const RED  = Color(1.33, 0, 0);
const CYAN = Color(0, 1.33, 1.33);

const CABLE_COLORS = [
	RED,
	CYAN,
]

func get_random_cable_color() -> Color:
	return CABLE_COLORS[randi_range(0, CABLE_COLORS.size())]

static var instancec = preload("res://scripts/colors.gd")

# static var instance: GlobalColors = preload("res://scripts/colors.gd")
