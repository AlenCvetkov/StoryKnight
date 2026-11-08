extends CharacterBody2D

@export var speed: float = 100.0
@export var gravity: float = 980.0

var target_player: Node2D = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if target_player != null:
		var direction = global_position.direction_to(target_player.global_position).x
		
		velocity.x = direction * speed
		
		if direction != 0:
			$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func _on_sight_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_player = body

func _on_sight_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null
