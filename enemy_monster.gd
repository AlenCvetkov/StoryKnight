extends CharacterBody2D

@export var speed: float = 100.0
@export var gravity: float = 980.0

var target_player: Node2D = null

func _ready() -> void:
	$Health.died.connect(_on_health_died)

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

func _on_health_died() -> void:
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
	await $AnimatedSprite2D.animation_finished
	queue_free()
