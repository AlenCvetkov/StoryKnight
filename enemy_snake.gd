extends CharacterBody2D

@export var speed: float = 100.0
@export var gravity: float = 980.0
@export var contact_damage: int = 5
@export var damage_interval: float = 1.0
@export var contact_range: float = 26.0

var target_player: Node2D = null
var is_dead: bool = false
var damage_cooldown_left: float = 0.0

func _ready() -> void:
	$Health.died.connect(_on_health_died)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if damage_cooldown_left > 0.0:
		damage_cooldown_left = maxf(damage_cooldown_left - delta, 0.0)

	if not is_on_floor():
		velocity.y += gravity * delta

	if target_player != null and is_instance_valid(target_player):
		var direction = global_position.direction_to(target_player.global_position).x
		velocity.x = direction * speed

		if direction != 0:
			$AnimatedSprite2D.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	_try_damage_player()

func _try_damage_player() -> void:
	if target_player == null or not is_instance_valid(target_player):
		return
	if damage_cooldown_left > 0.0:
		return
	if global_position.distance_to(target_player.global_position) > contact_range:
		return

	var player_health = target_player.get_node_or_null("Health")
	if player_health != null:
		player_health.call("take_damage", contact_damage)
		damage_cooldown_left = damage_interval

func _on_sight_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("player"):
		target_player = body

func _on_sight_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null

func _on_health_died() -> void:
	if is_dead:
		return
	is_dead = true
	target_player = null
	velocity = Vector2.ZERO
	set_physics_process(false)
	$HealthBar.hide()
	$Sight.set_deferred("monitoring", false)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	await $AnimatedSprite2D.animation_finished
	queue_free()
