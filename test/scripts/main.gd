extends Node2D

@onready var player: movement = $Player
@onready var terrain_map: TerrainMap = $TerrainMap
@onready var town_spawner: TownSpawner = $TownSpawner


func _ready() -> void:
	_conenct_signals()


func _conenct_signals() -> void:
	player.moved.connect(_on_player_moved)
	terrain_map.visible_cells_updated.connect(town_spawner.map_update)


func _on_player_moved(new_global_position : Vector2i) -> void:
	var player_in_middle : bool = true
	terrain_map.set_map_position(new_global_position, player_in_middle)
