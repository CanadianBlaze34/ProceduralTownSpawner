class_name CameraZoom extends Node

@export_category("Camera Zooming")
@export var _camera : Node
@export var _speed : float = 0.05
@export var _clamp := Vector2(0.25, 8.0)

var can_zoom : bool = true


func _unhandled_input(event : InputEvent) -> void:
	
	_flip_zooming(event)
	
	if not can_zoom:
		return
	
	_zoom(event)


func _flip_zooming(event : InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_TAB and event.pressed:
			can_zoom = !can_zoom


func _zoom(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		var direction : int = 0
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			direction = 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			direction = -1
		
		if direction != 0:
			_camera.zoom = _calculate_zoom(direction, _clamp, _speed, _camera.zoom)


func _calculate_zoom(direction : int, clamp_ : Vector2, speed : float, old_zoom : Vector2) -> Vector2:
	var new_zoom : float = old_zoom.x + direction * speed
	new_zoom = clamp(new_zoom, clamp_.x, clamp_.y)
	return new_zoom * Vector2.ONE


func reset_zoom() -> void:
	_camera.zoom = Vector2.ONE
