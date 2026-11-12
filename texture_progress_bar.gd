extends TextureProgressBar

@onready var health: Node = get_node("../Health")

func _ready() -> void:
	health.health_changed.connect(_on_health_changed)
	call_deferred("_sync_from_health")

func _sync_from_health() -> void:
	max_value = health.max_health
	value = health.current_health

func _on_health_changed(current_health: int) -> void:
	value = current_health
