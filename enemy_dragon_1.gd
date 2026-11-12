extends CharacterBody2D

@export var speed: float = 170.0
@export var contact_damage: int = 5
@export var damage_interval: float = 1.0
@export var contact_range: float = 38.0

var target_player: Node2D = null
var damage_cooldown_left: float = 0.0

func _ready() -> void:
	$Health.died.connect(_on_health_died)

func _physics_process(delta: float) -> void:
	if damage_cooldown_left > 0.0:
		damage_cooldown_left = maxf(damage_cooldown_left - delta, 0.0)

	if target_player != null and is_instance_valid(target_player):
		# Пресметуваме правец и по x и по y оската кон играчот
		var direction = global_position.direction_to(target_player.global_position)
		
		# Ја поставуваме брзината во сите правци (летање кон играчот)
		velocity = direction * speed
		
		# Свртување на спрајтот лево/десно според хоризонталниот правец
		if direction.x != 0:
			$AnimatedSprite2D.flip_h = direction.x < 0
	else:
		# Кога нема играч, постепено застанува во воздух (не паѓа)
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

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
	if body.is_in_group("player"):
		target_player = body

func _on_sight_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null

func _on_health_died() -> void:
	set_physics_process(false)
	velocity = Vector2.ZERO
	$Sight.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	queue_free()
