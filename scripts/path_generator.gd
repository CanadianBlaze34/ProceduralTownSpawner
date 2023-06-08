class_name PathGenerator # STATIC


static func border_inner_areas(areas : Array[Rect2i], original_area : Rect2i) -> PackedVector2Array:
	# generate positions along the border of the BSP_areas if
	# they aren't on the border of the towns area
	
	var positions := PackedVector2Array()
	
	for area in areas:
		# not at the top of the map
		if area.position.y != original_area.position.y:
			positions.append_array(Utility.lerp_line(area.position, Vector2(area.end.x, area.position.y)))
		
		# not at the bottom of the map
		if area.end.y != original_area.end.y:
			# draw the path not on the end of the rect but 1 before the end
			positions.append_array(Utility.lerp_line(Vector2(area.position.x, area.end.y - 1), area.end - Vector2i(0, 1)))
		
		# not at the left of the map
		if area.position.x != original_area.position.x:
			positions.append_array(Utility.lerp_line(area.position, Vector2(area.position.x, area.end.y)))
		
		# not at the right of the map
		if area.end.x != original_area.end.x:
			# draw the path not on the end of the rect but 1 before the end
			positions.append_array(Utility.lerp_line(Vector2(area.end.x - 1, area.position.y), area.end - Vector2i(1,0)))
	
	
	positions = Utility.remove_duplicates(positions)
	
	return positions

