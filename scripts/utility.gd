class_name Utility # STATIC

static func remove_duplicates(array: Array) -> Array:
	# https://ask.godotengine.org/61280/how-to-delete-reoccurring-values-from-a-list
	var unique: Array = []
	
	for item in array:
		if not unique.has(item):
			unique.append(item)
	
	return unique


static func lerp_line(start: Vector2, end: Vector2) -> PackedVector2Array:
	var line := PackedVector2Array()
	var distance : float = start.distance_to(end)
	var one_over_distance : float = 1.0 / distance
	
	for t in range(0, distance, 1):
		var position = start.lerp(end, t * one_over_distance)
		line.append(position)
	
	return line

