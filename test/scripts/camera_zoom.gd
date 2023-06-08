class_name CameraZoom extends Node

@export_category("Camera Zooming")
@export var camera : Camera2D
@export var slow_speed : float = 0.25
@export var min_zoom : float = 0.01
@export var max_zoom : float = 8.0

@export_category("Controls")
@export var slow_zoom_key : Key = KEY_SHIFT
@export var toggle_zoom_key : Key = KEY_TAB


var can_zoom : bool = true
var slow_zoom : bool = false


func _ready() -> void:
	_set_camera()


func _set_camera() -> void:
	if not camera:
		var parent : Node = get_parent()
		if parent is Camera2D:
			camera = parent as Camera2D
			push_warning("%ss parent has been set as the camera on ready." % [name])
		else:
			push_error("%ss camera is null." % [name])


func _unhandled_input(event : InputEvent) -> void:
	
	_flip_zooming(event)
	
	if not can_zoom:
		return
	
	_zoom(event)


func _process(_delta: float) -> void:
	_slow_zoom()


func _slow_zoom() -> void:
	# slow zooming speed while the shift key is being pressed 
	slow_zoom = Input.is_key_pressed(slow_zoom_key)


func _flip_zooming(event : InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == toggle_zoom_key and event.pressed:
			can_zoom = !can_zoom


func _zoom(event : InputEvent) -> void:
	var zoom_direction : int = 0
	var slow_zoom : bool = false
	
	if event is InputEventMouseButton:
		var scroll := event as InputEventMouseButton
		
		if scroll.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Mouse wheel scrolled up, zooming in, toward the max_zoom
			# things in the visible area get bigger, can see less area
			zoom_direction = 1
			# camera can zoom in 
			if camera.get_zoom().x >= max_zoom:
#				print("cant scroll up, zoom in more than the max_zoom.")
				return
			else:
#				print("scrolling up, zooming in.")
				pass
		elif scroll.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Mouse wheel scrolled down, zooming out, toward the min_zoom
			# things in the visible area get smaller, can see more area
			zoom_direction = -1
			# camera can zoom out 
			if camera.get_zoom().x <= min_zoom:
#				print("cant scroll down, zoom out less than the min_zoom.")
				return
			else:
#				print("scrolling down, zooming out.")
				pass
	
	# mouse wheel has been scrolled
	if zoom_direction:
		_calculate_zoom(zoom_direction)


func _calculate_zoom(zoom_direction : int) -> void:
	var current_zoom : float = camera.get_zoom().x
	
	# Slow down the zooming as it approaches the limits
	# slow down zoom even more when the shift button is being held
	var zoom_factor : float =(
		(current_zoom / (max_zoom - min_zoom))
		* (slow_speed if slow_zoom else 1.0)
	)
	
	var next_zoom = current_zoom + zoom_direction * zoom_factor
	next_zoom = clamp(next_zoom, min_zoom, max_zoom)

	# Set the new zoom level
	camera.set_zoom(next_zoom * Vector2.ONE)


func reset_zoom() -> void:
	camera.zoom = Vector2.ONE
