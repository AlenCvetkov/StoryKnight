extends Node2D

const PLATFORM_SCENE: PackedScene = preload("res://moving_fire_platform.tscn")
const BOX_CELLS: Array[Vector2i] = [
	Vector2i(36, 33),
	Vector2i(37, 33),
	Vector2i(38, 33),
]

func _ready() -> void:
	var tile_map := get_parent().get_node("map/TileMapLayer") as TileMapLayer
	for cell in BOX_CELLS:
		tile_map.erase_cell(cell)

	var platform := PLATFORM_SCENE.instantiate() as AnimatableBody2D
	platform.position = tile_map.map_to_local(Vector2i(37, 33))
	add_child(platform)
