class_name TileBase extends Resource

@export var source_id : int = -1
@export var atlas_coords : Vector2i = Vector2i(-1, -1)
@export var alternative_tile : int = -1

func set_cell(tile_map : TileMap, coords: Vector2i, layer : int = 0) -> void:
#	print(_layer, " ", coords, " ", source_id , " ", atlas_coords, " ", alternative_tile)
	tile_map.set_cell(layer, coords, source_id, atlas_coords, alternative_tile)

func remove_cell(tile_map : TileMap, coords: Vector2i, layer : int = 0) -> void:
	tile_map.set_cell(layer, coords)

func get_used_cells(tile_map : TileMap, layer : int = 0) -> Array[Vector2i]:
	return tile_map.get_used_cells_by_id(layer, source_id, atlas_coords, alternative_tile)

func print_properties() -> void:
	print("source id: %d\natlas coords: %v\nalternative tile: %d\n" % [source_id, atlas_coords, alternative_tile])
