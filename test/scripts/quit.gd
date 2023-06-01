extends Node

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("quit"):
		get_tree().quit()
