extends TextureProgressBar

@onready var health: Node = get_node("../Health")

func _ready() -> void:
	max_value = health.max_health
	value = health.current_health
	health.health_changed.connect(_on_health_changed)

func _on_health_changed(current_health: int) -> void:
	value = current_health
