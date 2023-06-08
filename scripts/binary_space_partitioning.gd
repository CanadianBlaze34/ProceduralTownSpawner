class_name BinarySpacePartitioning # STATIC

enum SpatialDirections{
	horizontal, # -
	vertical,   # |
}

static func partition(area : Rect2i, splits : int, min_area : Vector2i,
		ratio : float) -> Array[Rect2i]:
	
	var areas : Array[Rect2i] = []
	# areas that are too small to split
	var add_at_end_areas : Array[Rect2i] = []
	
	areas.append(area)
	
	for i in splits:
		
		var next_areas : Array[Rect2i] = areas.duplicate()
		areas.clear()
		
		for current_area in next_areas:
			var direction : SpatialDirections
			
			# both split childrens width has enough space to split vertically
			@warning_ignore("integer_division")
			var split_vertically : bool = current_area.size.x / 2 > min_area.x
			# both split childrens height has enough space to split horizontally
			@warning_ignore("integer_division")
			var split_horizontally : bool = current_area.size.y / 2 > min_area.y
			var split_both : bool = split_vertically and split_horizontally
			
			if split_both:
				direction = BinarySpacePartitioning._get_preferred_direction(current_area.size, ratio)
			else:
				if split_vertically:
					direction = SpatialDirections.vertical
				elif split_horizontally:
					direction = SpatialDirections.horizontal
				else:
					# add at the end to prevent doing this multiple times
					add_at_end_areas.append(current_area)
					continue
			
			var split_areas : Array[Rect2i] = BinarySpacePartitioning._split(current_area, min_area, direction)
			areas.append_array(split_areas)
	
	areas.append_array(add_at_end_areas)
	
	return areas


static func _get_preferred_direction(area_size : Vector2i, ratio : float = 1.2) -> SpatialDirections:
	
	# the width or height is way longer than needed compared to the other
	# split the way longer spatialDirection
	if area_size.x * ratio > area_size.y:
		return SpatialDirections.vertical
	elif area_size.y * ratio > area_size.x:
		return SpatialDirections.horizontal
	
	return BinarySpacePartitioning._random_direction()


static func _random_direction() -> SpatialDirections:
	return SpatialDirections.values()[randi() % SpatialDirections.size()]


static func _split(area: Rect2i, min_area : Vector2i, direction : SpatialDirections) -> Array[Rect2i]:
	
	var area1 : Rect2i
	var area2 : Rect2i
	
	# pick position orthogonal to the spatial direction 
	match direction:
		SpatialDirections.horizontal:
			var split_size_y : int = randi_range(min_area.y, area.size.y - min_area.y)
			area1 = Rect2i(area.position, Vector2i(area.size.x, split_size_y))
			area2 = Rect2i(area.position + Vector2i(0, split_size_y), area.size - Vector2i(0, split_size_y))
		SpatialDirections.vertical:
			var split_size_x : int = randi_range(min_area.x, area.size.x - min_area.x)
			area1 = Rect2i(area.position, Vector2i(split_size_x, area.size.y))
			area2 = Rect2i(area.position + Vector2i(split_size_x, 0), area.size - Vector2i(split_size_x, 0))
	
	return [area1, area2]
