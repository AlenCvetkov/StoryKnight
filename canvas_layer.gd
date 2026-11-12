extends CanvasLayer

@onready var player_health: Node = get_node("../Player/Health")
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var coins_label: Label = $CoinsLabel

func _ready() -> void:
	player_health.health_changed.connect(_on_health_changed)
	GameState.coins_changed.connect(_on_coins_changed)
	_on_coins_changed(GameState.coins)
	call_deferred("_sync_from_health")

func _sync_from_health() -> void:
	health_bar.max_value = player_health.max_health
	health_bar.value = player_health.current_health

func _on_health_changed(current_health: int) -> void:
	health_bar.value = current_health

func _on_coins_changed(amount: int) -> void:
	coins_label.text = "Монети: %d" % amount
