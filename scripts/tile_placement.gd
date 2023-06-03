class_name TilePlacement extends Node

@export var tile_map : TileMap
@export var _grass_tile : TileBase
@export var _water_tile : TileBase


func place_ground_tiles(tiles : Dictionary) -> void:
	# tiles : Dictionary[TileBase, Array[Vecctor2i]
	
	for tilebase in tiles.keys():
		var tile_positions: Array = tiles[tilebase]
		for tile_position in tile_positions:
			tilebase.set_cell(tile_map, tile_position)
	
	pass


func place_object_tiles(tiles : Array[TileBase]) -> void:
	pass

