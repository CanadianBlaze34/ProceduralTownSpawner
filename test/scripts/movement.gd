class_name movement extends CharacterBody2D

@export var speed : float = 300.0

signal moved(new_global_position : Vector2i)

func _physics_process(_delta: float) -> void:
	
	# Get the input direction and handle the movement/deceleration.
	var direction : Vector2 = Input.get_vector("walk_left", "walk_right",
		"walk_up", "walk_down")
	velocity = direction * speed
	
	move_and_slide()
	moved.emit(global_position)
