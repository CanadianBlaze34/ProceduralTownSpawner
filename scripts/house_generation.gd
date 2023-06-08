class_name HouseGeneration extends Node

@export var floor_tile : TileBase
@export var wall_tile : TileBase

func generate_houses(areas : Array[Rect2i], cell_area : Rect2i) -> Dictionary:
	# Dictionary[TileBase, Array[Vector2i]]
	# Dictionary[TileBase, tile_positions]
	var tiles : Dictionary = {}
	
	tiles[wall_tile] = []
	tiles[floor_tile] = []
	
#	var direction : Vector2i
	
	# use direction to make the door way
	for area in areas:
		var house_tiles := generate_house(area)
		tiles[wall_tile].append_array(house_tiles[wall_tile])
		tiles[floor_tile].append_array(house_tiles[floor_tile])
	
	return tiles


func generate_house(area : Rect2i) -> Dictionary:
	var tiles : Dictionary = {}
	
	tiles[wall_tile] = generate_wall(area)
	tiles[floor_tile] = generate_floor(area)
	
	return tiles


func generate_wall(area: Rect2i) -> PackedVector2Array:
	# make a square wall
	var positions := PackedVector2Array()
	var offset := Vector2i.ONE
	var wall_area := Rect2i(area.position + offset, area.size - offset - Vector2i.ONE)
	
	for x in range(wall_area.position.x, wall_area.end.x):
		positions.append(Vector2(x, wall_area.position.y)) # top, left to right
		positions.append(Vector2(x, wall_area.end.y - 1))  # bottom, left to right
	
	for y in range(wall_area.position.y + 1, wall_area.end.y - 1):
		positions.append(Vector2(wall_area.position.x, y)) # left, below top to above bottom
		positions.append(Vector2(wall_area.end.x - 1, y))  # right, below top to above bottom
	
	return positions


func generate_floor(area: Rect2i) -> PackedVector2Array:
	var positions := PackedVector2Array()
	# make a square wall
	var offset := Vector2i.ONE
	
	var wall_area := Rect2i(area.position + offset, area.size - offset - Vector2i.ONE)
	var floor_area := Rect2i(wall_area.position + offset, wall_area.size - offset - Vector2i.ONE)
	
	for y in range(floor_area.position.y, floor_area.end.y):
		for x in range(floor_area.position.x, floor_area.end.x):
			var position := Vector2(x, y)
			positions.append(position)
	
	return positions
