extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	GameState.has_golden_key = true
	print("Играчот го собра златниот клуч.")
	queue_free()
