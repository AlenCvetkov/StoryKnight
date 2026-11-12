extends Node2D

@onready var coin_pickup_sound: AudioStreamPlayer2D = $CoinPickupSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for coin in get_children():
		if coin is Area2D:
			coin.body_entered.connect(_on_coin_body_entered.bind(coin))

func _on_coin_body_entered(body: Node2D, coin: Area2D) -> void:
	if not body.is_in_group("player"):
		return
	
	GameState.add_coin()
	coin_pickup_sound.global_position = coin.global_position
	coin_pickup_sound.play()
	coin.queue_free()
