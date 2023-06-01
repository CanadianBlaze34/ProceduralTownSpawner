class_name TownSpawner extends Node2D

# chance to spawn towns based on grids/chunk
@export var spawn_chunk_cell_size := Vector2i.ONE * 50
@export_range(0.0, 1.0, 0.01) var spawn_chance : float = 0.34
@export var town_generator : TownGenerator
@export var random := FastNoiseLite.new()

var towns : Dictionary = {}

signal town_added(town)
signal town_removed(town)

func map_update(visible_cell_area : Rect2i) -> void:
	var visible_chunk_area := Rect2i(to_chunk_position(visible_cell_area.position), Vector2i.ZERO)
	visible_chunk_area.end = to_chunk_position(visible_cell_area.end)
	# include the edge of the area
	visible_chunk_area.size += Vector2i.ONE
#	print(visible_cell_area)
#	print(visible_chunk_area)
	_spawn_towns(visible_chunk_area)
	_remove_towns(visible_chunk_area)


func _spawn_towns(visible_chunk_area : Rect2i) -> void:
	# check for any new chunks walked into and spawn a town
	for y in range(visible_chunk_area.position.y, visible_chunk_area.end.y):
		for x in range(visible_chunk_area.position.x, visible_chunk_area.end.x):
			
			var chunk_position := Vector2i(x, y)
			
			if town_at(chunk_position) and not chunk_position in towns:
				print("add: %v" % chunk_position)
				
				var town = town_generator.generate_town(chunk_position, spawn_chunk_cell_size)
				towns[chunk_position] = town
				add_child(town)
				
				town_added.emit(town)


func _remove_towns(visible_chunk_area : Rect2i) -> void:
	# remove towns in non-visible chunks
	for chunk_position in towns.keys():
		if not visible_chunk_area.has_point(chunk_position):
			print("remove: %v" % chunk_position)
			
			var town = towns[chunk_position]
			towns.erase(chunk_position)
			remove_child(town)
			
			town_removed.emit(town)


func town_at(chunk_position : Vector2) -> bool:
	var noise01 : float = random.get_noise_2dv(chunk_position) * 0.5 + 0.5
	var town_in_chunk : bool = noise01 < spawn_chance
	return town_in_chunk


func to_chunk_position(cell_position : Vector2) -> Vector2i:
	return TownSpawner.cell_to_chunk_position(self, cell_position, spawn_chunk_cell_size)


static func cell_to_chunk_position(parent: Node2D, cell_position : Vector2, chunk_size : Vector2i) -> Vector2i:
	var local_popsition_ := parent.to_local(cell_position)
	var chunk_position : Vector2i = (local_popsition_ / Vector2(chunk_size)).floor()
	return chunk_position

