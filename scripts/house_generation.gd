class_name HouseGeneration extends Node

@export var floor_tile : TileBase
@export var wall_tile : TileBase

func generate_house(cell_area : Rect2i, direction : Vector2i) -> Dictionary:
	# Dictionary[TileBase, Array[Vector2i]]
	# Dictionary[TileBase, tile_positions]
	var tiles : Dictionary = {}
	
	# use direction to make the door way
	# make a basic square wall
	# make a square inside the walls for the floor
	
	return tiles
