class_name TownGenerator extends Node

@export var _grass_tile : TileBase
@export var _water_tile : TileBase
@export var _path_tile : TileBase
@export var tile_map : TileMap
@export var house_generation : HouseGeneration
@export var random := FastNoiseLite.new()

const ground_layer : String = "ground"
const object_layer : String = "object"

func generate_name() -> String:
	var name_ : String = "Unamed Town"
	return name_


func generate_town(chunk_position : Vector2i, spawn_chunk_cell_size : Vector2i) -> Array:
	# intilize town
	var town := Node2D.new()
	town.name = generate_name()
	
	# area boundaries
	var area : Area2D = _generate_town_boundary(chunk_position, spawn_chunk_cell_size)
	area.name = "TownBoundary"
	var collision : CollisionShape2D = area.get_child(0)
	
	# areas in different dimensions
	var town_area := Rect2i(area.position, collision.shape.size)
	var cell_area := Rect2i(town_area.position / tile_map.tile_set.tile_size, town_area.size / tile_map.tile_set.tile_size)
	
	
	# areas used to generate the path tiles and spawn houses
	var plot_areas : Array[Rect2i] = _generate_areas(cell_area)
	
	# Dictionary[TileBase, Array[Vector2i]]
	# Dictionary[TileBase, cell_positions]
	var grass_tiles : Dictionary = _fill_with_grass(cell_area)
	var path_tiles_and_modified_areas : Array = _generate_path(plot_areas, cell_area)
	var path_tiles : Dictionary = path_tiles_and_modified_areas[0]
	var modified_areas : Array[Rect2i] = path_tiles_and_modified_areas[1]
	var house_tiles : Dictionary = _generate_houses(modified_areas, cell_area)
	
	var tiles : Dictionary = {
		ground_layer : [grass_tiles, path_tiles],
		object_layer : [house_tiles]
	}
	
	town.add_child(area)
	town.name = "Town"
	
	return [town, tiles]


func _generate_areas(area : Rect2i) -> Array[Rect2i]:
	var splits : int = randi_range(3, 5)
	var min_area := Vector2i.ONE * randi_range(6, 8)
	var ratio : float = randf_range(1.2, 1.4)
	var BSP_areas : Array[Rect2i] = BinarySpacePartitioning.partition(area, splits, min_area, ratio)
	return BSP_areas


func _generate_path(areas : Array[Rect2i], cell_area : Rect2i) -> Array:
	var path_tiles : Dictionary = {} # Dictionary[TileBase, Array[Vector2i]]
	
	path_tiles[_path_tile] = []
	
	var positions_and_modified_areas : Array = PathGenerator.paths_and_areas(areas, cell_area)
	var positions : PackedVector2Array = positions_and_modified_areas[0]
	var modified_areas : Array[Rect2i] = positions_and_modified_areas[1] as Array[Rect2i]
	
	
	for position_ in positions:
		path_tiles[_path_tile].append(Vector2i(position_))
	
	return [path_tiles, modified_areas]


func _generate_houses(areas : Array[Rect2i], cell_area : Rect2i) -> Dictionary:
	var house_tiles : Dictionary # Dictionary[TileBase, Array[Vector2i]]
	
	house_tiles = house_generation.generate_houses(areas, cell_area)
	
	return house_tiles


func _fill_with_grass(cell_area : Rect2i) -> Dictionary:
	var grass_tiles : Dictionary = {} # Dictionary[TileBase, Array[Vector2i]]
	
	grass_tiles[_grass_tile] = []
	
	for y in range(cell_area.position.y, cell_area.end.y):
		for x in range(cell_area.position.x, cell_area.end.x):
			var map_position := Vector2i(x, y)
			grass_tiles[_grass_tile].append(map_position)

	return grass_tiles


func _generate_town_boundary(chunk_position : Vector2i, spawn_chunk_cell_size : Vector2i) -> Area2D:
	const margin : int = 10
	const minimum_size : int = 15
	
	var collision := _generate_town_collision(chunk_position, spawn_chunk_cell_size, margin, minimum_size)
	
	var collision_tile_size : Vector2i = Vector2i(collision.shape.size) / tile_map.tile_set.tile_size
	var area := _generate_town_area(chunk_position, spawn_chunk_cell_size, collision_tile_size)
	
	area.add_child(collision)
	# position the collisions top left corner at the areas position 
	collision.position = collision.shape.size * 0.5
	
	return area


func _generate_town_area(chunk_position : Vector2i, spawn_chunk_cell_size : Vector2i, size : Vector2i) -> Area2D:
	var noise_value : float = random.get_noise_2dv(chunk_position) * 0.5 + 0.5
	var noise_value2 : float = random.get_noise_2d(chunk_position.y, chunk_position.x) * 0.5 + 0.5
	var area := Area2D.new()
	
	var global_chunk_position : Vector2i = chunk_position * spawn_chunk_cell_size
	var possible_position_size : Vector2 = spawn_chunk_cell_size - size
	var chunk_offset_position := Vector2i(Vector2(noise_value, noise_value2) * possible_position_size)
	var global_position_ : Vector2 = (global_chunk_position + chunk_offset_position) * tile_map.tile_set.tile_size
	# constant position for debugging
#	var global_position_ : Vector2 = global_chunk_position * tile_map.tile_set.tile_size + tile_map.tile_set.tile_size
	area.global_position = global_position_
	area.position = global_position_
	
	return area


func _generate_town_collision(chunk_position : Vector2i, spawn_chunk_cell_size : Vector2i, margin : int, minimum_size : int) -> CollisionShape2D:
	var noise_value : float = random.get_noise_2dv(chunk_position * chunk_position) * 0.5 + 0.5
	var noise_value2 : float = random.get_noise_2d((chunk_position * chunk_position).y, (chunk_position * chunk_position).x) * 0.5 + 0.5
	var collision := CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2i(
		(minimum_size + int(noise_value * (spawn_chunk_cell_size.x - margin - minimum_size))), 
		(minimum_size + int(noise_value2 * (spawn_chunk_cell_size.y - margin - minimum_size)))) * tile_map.tile_set.tile_size 
	# constant size for debugging
#	collision.shape.size = (spawn_chunk_cell_size - Vector2i.ONE * 2) * tile_map.tile_set.tile_size
	return collision
