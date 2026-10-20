extends Node2D
signal player_entered_rack(rack)
signal player_exited_rack(rack)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_player_entered_rack)
	$InteractionArea.body_exited.connect(_on_player_exited_rack)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_entered_rack(body):
	if (body.is_in_group("Player")):
		player_entered_rack.emit(self)

func _on_player_exited_rack(body):
	if (body.is_in_group("Player")):
		player_exited_rack.emit(self)
