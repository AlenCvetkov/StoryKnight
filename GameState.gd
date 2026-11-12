extends Node

signal coins_changed(amount: int)

var has_golden_key: bool = false
var door_unlocked: bool = false
var coins: int = 0


func add_coin() -> void:
	coins += 1
	coins_changed.emit(coins)
