class_name TerrainMap extends TileMap

@export var _noise := FastNoiseLite.new()
@export var _grass_tile : TileBase
@export var _water_tile : TileBase

const _edge_padding : int = 1
const _v_edge_padding := Vector2i.ONE * _edge_padding

var _map_position := Vector2i.ZERO

signal visible_cells_updated(visible_cells : Rect2i)


func _get_viewport_map_size() -> Vector2i:
	# https://godotengine.org/qa/234/how-to-get-the-screen-dimensions-in-gdscript
	var viewport_size : Vector2i = get_viewport().get_visible_rect().size
#	print("Viewport size %v" % [viewport_size])
	var viewport_map_size := Vector2i((Vector2(viewport_size) / Vector2(tile_set.tile_size)).ceil())
#	print("Viewport map size %v" % [viewport_map_size])
	return viewport_map_size


func _center_position_in_viewport(_global_position : Vector2) -> Vector2:
	# offset by half the viewport size so the position is placed at
	# the top of the viewport
	var viewport_half_size : Vector2 = get_viewport().get_visible_rect().size / 2
	var camera_top_left : Vector2i = _global_position - viewport_half_size
#	print("camera top left %v" % [camera_top_left])
	return camera_top_left


func set_map_position(_global_position : Vector2, center_position : bool) -> void:
	# move in the oppisite direction of the position to create the
	# illusion that the map is moving in the direction away from
	# the walking entity
	
	if center_position:
		# the map generation will start at the top of the viewport
		_global_position = _center_position_in_viewport(_global_position)
	
	var updated_map_position : Vector2i = TerrainMap.global_to_map(self, _global_position)
	
	if updated_map_position != _map_position:
		var map_move_direction : Vector2i = updated_map_position - _map_position
		_map_position = updated_map_position
#		print("map position: %v" % [_map_position])
		_update_cells(map_move_direction)


func _update_cells(_direction : Vector2i) -> void:
	var viewport_map_size : Vector2 = _get_viewport_map_size()
	_update_cells_in_rect(viewport_map_size, _edge_padding)


func _update_cells_in_rect(map_size : Vector2i, edge_padding : int) -> void:
		
	var v_edge_padding := Vector2i.ONE * edge_padding # v = vector
	var visible_map := Rect2i(_map_position - v_edge_padding, map_size + v_edge_padding)
	
	# clear all tiles/cells in the tilemap
	clear()
	
#	print("visible map %v %v" % [visible_map.position, visible_map.end])
	for y in range(visible_map.position.y, visible_map.end.y + 1):
		for x in range(visible_map.position.x, visible_map.end.x + 1):
			var cell : = Vector2i(x, y)
			var tile : TileBase = _tile_at(cell)
			tile.set_cell(self, cell)
	
	visible_cells_updated.emit(visible_map)


func _tile_at(map_position : Vector2i) -> TileBase:
	
	var noise_value : float = _noise.get_noise_2dv(map_position)
	# Convert [-1, 1] to [0, 1]
	noise_value = clamp(noise_value * 0.5 + 0.5, 0.0, 1.0)
	
	var tile : TileBase = _grass_tile if noise_value >= 0.5 else _water_tile
	
	return tile


# Utility functions

static func global_to_map(tile_map : TileMap, _global_position : Vector2) -> Vector2i:
	return tile_map.local_to_map(tile_map.to_local(_global_position))

