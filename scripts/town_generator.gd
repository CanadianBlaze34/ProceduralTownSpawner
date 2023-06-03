class_name TownGenerator extends Node

@export var _grass_tile : TileBase
@export var _water_tile : TileBase
@export var _path_tile : TileBase
@export var tile_map : TileMap
@export var random := FastNoiseLite.new()

func _ready() -> void:
#	_test()
	pass

func _test() -> void:
	var chunk_position := Vector2i(0, 0)
	var spawn_chunk_cell_size := Vector2i(50, 50)
	var town_and_tiles : Array = generate_town(chunk_position, spawn_chunk_cell_size)
	var town : Node2D = town_and_tiles[0]
#	var tiles : Dictionary = town_and_tiles[1]
	add_child(town)


func generate_town(chunk_position : Vector2i, spawn_chunk_cell_size : Vector2i) -> Array:
	var name_ : String = "Unamed Town"
	var town := Node2D.new()
	town.name = name_
	
	var area : Area2D = _generate_town_boundary(chunk_position, spawn_chunk_cell_size)
	area.name = "TownBoundary"
	var collision : CollisionShape2D = area.get_child(0)
	var town_area := Rect2i(area.position, collision.shape.size)
	
	var grass_tiles : Dictionary = _fill_with_grass(town_area)
	var tiles : Dictionary = {
		"ground" : grass_tiles,
	}
	
	town.add_child(area)
	town.name = "Town"
	
	return [town, tiles]

func _fill_with_grass(cell_area : Rect2i) -> Dictionary:
	var grass_tiles : Dictionary = {} # Dictionary[TileBase, Array[Vector2i]]
	
	grass_tiles[_path_tile] = []
	
	for y in range(cell_area.position.y, cell_area.end.y + 1):
		for x in range(cell_area.position.x, cell_area.end.x + 1):
			var map_position := Vector2i(x, y)
			grass_tiles[_path_tile].append(map_position)

	return grass_tiles

func _generate_town_boundary(chunk_position : Vector2i, spawn_chunk_cell_size : Vector2i) -> Area2D:
	const margin : int = 10
	const minimum_size : int = 15
	
	var area := _generate_town_area(chunk_position, spawn_chunk_cell_size, margin)
	var collision := _generate_town_collision(chunk_position, spawn_chunk_cell_size, margin, minimum_size)
	area.add_child(collision)
	# position the collisions top left corner at the areas position 
	collision.position = collision.shape.size * 0.5
	
	return area


func _generate_town_area(chunk_position : Vector2i, spawn_chunk_cell_size : Vector2i, margin : int) -> Area2D:
	var noise_value : float = random.get_noise_2dv(chunk_position) * 0.5 + 0.5
	var noise_value2 : float = random.get_noise_2d(chunk_position.y, chunk_position.x) * 0.5 + 0.5
	var area := Area2D.new()
	
	var global_chunk_position : Vector2i = chunk_position * spawn_chunk_cell_size
	@warning_ignore("integer_division", "narrowing_conversion")
	var chunk_offset_position := Vector2i(noise_value, noise_value2) * (margin / 2)
	var global_position_ : Vector2 = (global_chunk_position + chunk_offset_position) * tile_map.tile_set.tile_size
	area.global_position = global_position_
	
	return area


func _generate_town_collision(chunk_position : Vector2i, spawn_chunk_cell_size : Vector2i, margin : int, minimum_size : int) -> CollisionShape2D:
	var noise_value : float = random.get_noise_2dv(chunk_position * chunk_position) * 0.5 + 0.5
	var noise_value2 : float = random.get_noise_2d((chunk_position * chunk_position).y, (chunk_position * chunk_position).x) * 0.5 + 0.5
	var collision := CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2i(
		(minimum_size + int(noise_value * (spawn_chunk_cell_size.x - margin - minimum_size))), 
		(minimum_size + int(noise_value2 * (spawn_chunk_cell_size.y - margin - minimum_size)))) * tile_map.tile_set.tile_size 
	return collision
