class_name HouseGeneration extends Node

@export var floor_tile : TileBase
@export var wall_tile : TileBase

enum Directions {
	up,
	right,
	down,
	left
}

func generate_houses(areas : Array[Rect2i], cell_area : Rect2i) -> Dictionary:
	# Dictionary[TileBase, Array[Vector2i]]
	# Dictionary[TileBase, tile_positions]
	var tiles : Dictionary = {}
	
	tiles[wall_tile] = []
	tiles[floor_tile] = []
	
	# use direction to make the door way
	for area in areas:
		if cant_generate_house(area):
			continue
		var house_tiles := generate_house(area)
		tiles[wall_tile].append_array(house_tiles[wall_tile])
		tiles[floor_tile].append_array(house_tiles[floor_tile])
	
	return tiles

func cant_generate_house(area : Rect2i) -> bool:
	var generate : bool = true
	
	var floor_area : Rect2i = _floor_area(area)
	var size_restriction := Vector2i.ONE * 3
	
	if floor_area.size.x < size_restriction.x or\
		floor_area.size.y < size_restriction.y:
		generate = false
	
	return not generate

func generate_house(area : Rect2i) -> Dictionary:
	var tiles : Dictionary = {}
	
	var door_positions : PackedVector2Array = generate_door(area)
	tiles[wall_tile] = generate_wall(area)
	tiles[floor_tile] = generate_floor(area)
	
	for door_position in door_positions:
		var index : int = tiles[wall_tile].find(door_position)
		tiles[floor_tile].append(door_position)
		tiles[wall_tile].remove_at(index)
	
	return tiles

func generate_door(area: Rect2i) -> PackedVector2Array:
	
	var random_factor : int = randi()
	
	var random_direction : Directions = Directions.values()[random_factor % Directions.size()]
	
	var wall_area : Rect2i = _wall_area(area)
	
	var max_door_length : int = 2
	
	var positions : PackedVector2Array = _generate_door_positions(wall_area,
		max_door_length, random_direction, random_factor)
	
	return positions


func _generate_door_positions(wall_area: Rect2i, max_door_length : int,
		direction : Directions, random_factor : int) -> PackedVector2Array:
	
	var positions := PackedVector2Array()
	
	# corners per dimension
	const wall_corners : int = 2
	var corner_offset : int = 1
	var wall_size_without_corners : Vector2i = wall_area.size - Vector2i.ONE * wall_corners
	
	if direction == Directions.up or direction == Directions.down: # is a vertical direction
		# spawn a door along the horizontal walls
		var vertical_position : int = 0 if direction == Directions.up else (wall_area.size.y - 1) # relative to the wall_area
		if wall_size_without_corners.x == 3: # spawn the single door in the center
			var center_offset : int = 1
			positions.append(Vector2i(corner_offset + center_offset, vertical_position) + wall_area.position)
		else:
			# spawn a door of length 1 or 2 randomly along the width
			var door_size : int = (random_factor % max_door_length) + 1 # [1, 2]
			var door_position := Vector2i(random_factor % (wall_size_without_corners.x - door_size), 0) +\
				Vector2i(corner_offset, vertical_position) + wall_area.position
			for x in door_size:
				positions.append(door_position + Vector2i(x, 0))
	else: # is a horizontal direction
		# spawn a door along the vertical walls
		var horizontal_position : int = 0 if direction == Directions.left else (wall_area.size.x - 1) # relative to the wall_area
		if wall_size_without_corners.y == 3: # spawn the single door in the center
			var center_offset : int = 1
			positions.append(Vector2i(horizontal_position, corner_offset + center_offset) + wall_area.position)
		else:
			# spawn a door of length 1 or 2 randomly along the width
			var door_size : int = (random_factor % max_door_length) + 1 # [1, 2]
			var door_position := Vector2i(0, random_factor % (wall_size_without_corners.y - door_size)) +\
				Vector2i(horizontal_position, corner_offset) + wall_area.position
			for y in door_size:
				positions.append(door_position + Vector2i(0, y))
	
	return positions


func generate_wall(area: Rect2i) -> PackedVector2Array:
	# make a square wall
	var positions := PackedVector2Array()
	var wall_area : Rect2i = _wall_area(area)
	
	for x in range(wall_area.position.x, wall_area.end.x):
		positions.append(Vector2(x, wall_area.position.y)) # top, left to right
		positions.append(Vector2(x, wall_area.end.y - 1))  # bottom, left to right
	
	for y in range(wall_area.position.y + 1, wall_area.end.y - 1):
		positions.append(Vector2(wall_area.position.x, y)) # left, below top to above bottom
		positions.append(Vector2(wall_area.end.x - 1, y))  # right, below top to above bottom
	
	return positions


func generate_floor(area: Rect2i) -> PackedVector2Array:
	var positions := PackedVector2Array()
	
	var floor_area : Rect2i = _floor_area(area)
	
	for y in range(floor_area.position.y, floor_area.end.y):
		for x in range(floor_area.position.x, floor_area.end.x):
			var position := Vector2(x, y)
			positions.append(position)
	
	return positions


func _wall_area(area : Rect2i, offset := Vector2i.ONE) -> Rect2i:
	var wall_area := Rect2i(area.position + offset, area.size - offset - Vector2i.ONE)
	return wall_area


func _floor_area(area : Rect2i, wall_offset := Vector2i.ONE, floor_offset := Vector2i.ONE) -> Rect2i:
	var wall_area : Rect2i = _wall_area(area, wall_offset)
	var floor_area := Rect2i(wall_area.position + floor_offset, wall_area.size - floor_offset - Vector2i.ONE)
	return floor_area
