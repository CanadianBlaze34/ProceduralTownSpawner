class_name TownSpawner extends Node2D

# chance to spawn towns based on grids/chunk
@export var spawn_chunk_cell_size := Vector2i.ONE * 50
@export_range(0.0, 1.0, 0.01) var spawn_chance : float = 0.34
@export var town_generator : TownGenerator
@export var tile_placement : TilePlacement
@export var random := FastNoiseLite.new()

const ground_layer : String = "ground"
const object_layer : String = "object"

var towns : Dictionary = {} 
# Dictionary[Vector2i, Array[Node2D, Dictionary[TileBase, Array[Vector2i]]]]
# towns[chunk_position, Array[town, tiles[TileBase, cell_positions]]]

signal town_added(town)
signal town_removed(town)

func map_update(visible_cell_area : Rect2i) -> void:
	var visible_chunk_area := Rect2i(to_chunk_position(visible_cell_area.position), Vector2i.ZERO)
	visible_chunk_area.end = to_chunk_position(visible_cell_area.end)
	# include the edge of the area
	visible_chunk_area.size += Vector2i.ONE
#	print("visible cell area: ", visible_cell_area, " E: %v" % visible_cell_area.end)
#	print("visible chunk area: ", visible_chunk_area, " E: %v" % visible_chunk_area.end)
	
	_spawn_towns(visible_chunk_area)
	_remove_towns(visible_chunk_area)


func _place_town_tiles(tiles : Dictionary) -> void:
	# parameters should have the tiles to place and the layers to place the tiles in
	tile_placement.place_tiles(tiles[ground_layer], ground_layer)
#	tile_placement.place_tiles(tiles[object_layer], object_layer)
	pass


func _remove_town_tiles(tiles : Dictionary) -> void:
	# parameters should have the tiles to place and the layers to place the tiles in
	tile_placement.remove_tiles(tiles[ground_layer], ground_layer)
#	tile_placement.remove_tiles(tiles[object_layer], object_layer)
	pass


func _spawn_towns(visible_chunk_area : Rect2i) -> void:
	# check for any new chunks walked into and spawn a town
	for y in range(visible_chunk_area.position.y, visible_chunk_area.end.y):
		for x in range(visible_chunk_area.position.x, visible_chunk_area.end.x):
			
			var chunk_position := Vector2i(x, y)
			
			if town_at(chunk_position) and not chunk_position in towns:
				print("add town to chunk: %v" % chunk_position)
				
				var town_and_tiles : Array = town_generator.generate_town(chunk_position, spawn_chunk_cell_size)
				var town : Node2D = town_and_tiles[0]
				var tiles : Dictionary = town_and_tiles[1]
				
				towns[chunk_position] = [town, tiles]
				_place_town_tiles(tiles)
				add_child(town)
				town_added.emit(town)


func _remove_towns(visible_chunk_area : Rect2i) -> void:
	# remove towns in non-visible chunks
	for chunk_position in towns.keys():
		if not visible_chunk_area.has_point(chunk_position):
			print("remove town from chunk: %v" % chunk_position)
			
			var town = towns[chunk_position][0]
			var tiles = towns[chunk_position][1]
			
			towns.erase(chunk_position)
			_remove_town_tiles(tiles)
			remove_child(town)
			
			town_removed.emit(town)


func town_at(chunk_position : Vector2) -> bool:
	var noise01 : float = random.get_noise_2dv(chunk_position) * 0.5 + 0.5
	var town_in_chunk : bool = noise01 < spawn_chance
	return town_in_chunk


func to_chunk_position(cell_position : Vector2) -> Vector2i:
	return TownSpawner.cell_to_chunk_position(cell_position, spawn_chunk_cell_size)


static func cell_to_chunk_position(cell_position : Vector2, chunk_size : Vector2i) -> Vector2i:
	var chunk_position : Vector2i = (cell_position / Vector2(chunk_size)).floor()
	return chunk_position

