class_name PathGenerator # STATIC


static func paths_and_areas(areas : Array[Rect2i], original_area : Rect2i) -> Array: # Array[PackedVector2Array, Array[Rect2i]]
	# returns [positions, modified_areas]
	
	# generate positions along the border of the areas if
	# they aren't on the border of the towns area
	
	# also return modified_areas that have the path dimensions removed from them
	# modified_area = old_area - path_dimensions
	# the area is used to spawn something(a house) in it
	
	var positions := PackedVector2Array()
	var modified_areas : Array[Rect2i] = []
	
	for area in areas:
		
		var modified_area := Rect2i(area)
		
		# not at the top of the map
		if area.position.y != original_area.position.y:
			# add top row of the area
			positions.append_array(Utility.lerp_line(area.position, Vector2(area.end.x, area.position.y)))
			# remove top row of the modified_area
			# move the modified_area down by one and decrease the height by one 
			modified_area.position.y += 1
			modified_area.size.y -= 1
		
		# not at the bottom of the map
		if area.end.y != original_area.end.y:
			# draw the path not on the end of the rect but 1 before the end
			# add bottom row of the area
			positions.append_array(Utility.lerp_line(Vector2(area.position.x, area.end.y - 1), area.end - Vector2i(0, 1)))
			# remove bottom row of the modified_area
			# decrease the modified_areas height by one 
			modified_area.size.y -= 1
		
		# not at the left of the map
		if area.position.x != original_area.position.x:
			# add left column of the area
			positions.append_array(Utility.lerp_line(area.position, Vector2(area.position.x, area.end.y)))
			# remove left column of the modified_area
			# move the modified_area right by one and decrease the width by one 
			modified_area.position.x += 1
			modified_area.size.x -= 1
		
		# not at the right of the map
		if area.end.x != original_area.end.x:
			# draw the path not on the end of the rect but 1 before the end
			# add right column of the area
			positions.append_array(Utility.lerp_line(Vector2(area.end.x - 1, area.position.y), area.end - Vector2i(1,0)))
			# remove right column of the modified_area
			# decrease the modified_areas width by one 
			modified_area.size.x -= 1
		
		modified_areas.append(modified_area)
	
	positions = Utility.remove_duplicates(positions)
	
	return [positions, modified_areas]

