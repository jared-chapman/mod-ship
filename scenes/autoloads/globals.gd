extends Node

signal debug_changed(enabled: bool)

var debug: bool = true:
	set(value):
		if debug == value: return
		debug = value
		debug_changed.emit(debug)
