class_name TilePlacement extends Node

@export var tile_map : TileMap
@export var _grass_tile : TileBase
@export var _water_tile : TileBase


func place_tiles(tiles : Dictionary, layer_name : String) -> void:
	# tiles : Dictionary[TileBase, Array[Vecctor2i]
	
	var layer : int = _find_layer(layer_name)
	
	if layer == -1:
		var error_message : String = "'%s' layer not found in Tilemap %s." % [layer_name, tile_map.name]
		push_warning(error_message)
#		push_error(error_message)
		print(error_message)
		return
	
	for tilebase in tiles.keys():
		var tile_positions: Array = tiles[tilebase]
#		print("placing %d positions in %s Tilemaps' '%s' layer." % [tile_positions.size(), tile_map.name, layer_name])
		
		for tile_position in tile_positions:
			tilebase.set_cell(tile_map, tile_position, layer)


func remove_tiles(tiles : Dictionary, layer_name : String) -> void:
	# tiles : Dictionary[TileBase, Array[Vecctor2i]
	
	var layer : int = _find_layer(layer_name)
	
	if layer == -1:
		var error_message : String = "'%s' layer not found in Tilemap %s." % [layer_name, tile_map.name]
		push_warning(error_message)
#		push_error(error_message)
		print(error_message)
		return
	
	for tilebase in tiles.keys():
		var tile_positions: Array = tiles[tilebase]
#		print("placing %d positions in %s Tilemaps' '%s' layer." % [tile_positions.size(), tile_map.name, layer_name])
		
		for tile_position in tile_positions:
			tilebase.remove_cell(tile_map, tile_position, layer)


func _find_layer(layer_name : String) -> int:
	var index : int = -1
	
	for layer in tile_map.get_layers_count():
		if tile_map.get_layer_name(layer) == layer_name:
			index = layer
			break
	
	return index
