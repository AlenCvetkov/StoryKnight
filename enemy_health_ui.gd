extends Node2D

@onready var health: Node = get_node("../Health")
@onready var hearts: Array[Sprite2D] = [$Heart1, $Heart2]

@export var full_heart: Texture2D
@export var half_heart: Texture2D
@export var empty_heart: Texture2D

func _ready() -> void:
	health.health_changed.connect(update_hearts)
	update_hearts(health.current_health)

func update_hearts(value: int) -> void:
	var per_heart := float(health.max_health) / hearts.size()
	for i in hearts.size():
		var heart_value := (i + 1) * per_heart
		if value >= heart_value:
			hearts[i].texture = full_heart
		elif value >= heart_value - per_heart / 2.0:
			hearts[i].texture = half_heart
		else:
			hearts[i].texture = empty_heart
