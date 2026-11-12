extends CharacterBody2D

@export var speed: float = 160.0
@export var gravity: float = 980.0
@export var knockback_duration: float = 0.15
@export var knockback_friction: float = 1500.0
@export var attack_damage: int = 10
@export var attack_interval: float = 3.0
@export var golden_key_scene: PackedScene
var attack_timer: float = 0.6

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const ANIMATION_FOOT_OFFSETS: Dictionary = {
	"idle": 15.0,
	"run": 13.5,
	"attack": 36.4,
	"die": 15.5,
}

var target_player: Node2D = null
var is_dead: bool = false
var player_in_attack_range: bool = false
var knockback_time_remaining: float = 0.0
var knockback_velocity_x: float = 0.0

func _align_animation_to_collider(animation_name: String) -> void:
	var body_shape := $CollisionShape2D.shape as RectangleShape2D
	if body_shape == null:
		return
	var foot_offset: float = float(ANIMATION_FOOT_OFFSETS.get(animation_name, ANIMATION_FOOT_OFFSETS["idle"]))


func _play_animation(animation_name: String) -> void:
	_align_animation_to_collider(animation_name)
	animated_sprite_2d.play(animation_name)

func _ready() -> void:
	$Health.died.connect(_on_health_died)
	animated_sprite_2d.animation_changed.connect(_on_animation_changed)
	_align_animation_to_collider("idle")

func _on_animation_changed() -> void:
	# Keep every animation aligned, including ones started by another script (for example Health.die()).
	_align_animation_to_collider(String(animated_sprite_2d.animation))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if knockback_time_remaining > 0.0:
		knockback_time_remaining = maxf(knockback_time_remaining - delta, 0.0)
		velocity.x = knockback_velocity_x
		knockback_velocity_x = move_toward(knockback_velocity_x, 0.0, knockback_friction * delta)
	elif player_in_attack_range:
		velocity.x = 0.0
		attack_timer -= delta

		if attack_timer <= 0.0:
			_play_animation("attack")
			_damage_player()
			attack_timer = attack_interval
	elif target_player != null and is_instance_valid(target_player):
		var direction := global_position.direction_to(target_player.global_position).x
		velocity.x = direction * speed
		if direction != 0.0:
			animated_sprite_2d.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

	move_and_slide()

func apply_knockback(from_position: Vector2, strength: float = 220.0) -> void:
	if is_dead:
		return
	var direction: float
	if global_position.x > from_position.x:
		direction = 1.0
	elif global_position.x < from_position.x:
		direction = -1.0
	else:
		direction = -1.0 if animated_sprite_2d.flip_h else 1.0
	knockback_velocity_x = direction * strength
	knockback_time_remaining = knockback_duration

func _on_sight_body_entered(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	target_player = body
	if not player_in_attack_range:
		_play_animation("run")

func _on_sight_body_exited(body: Node2D) -> void:
	if is_dead or body != target_player:
		return
	target_player = null
	if not player_in_attack_range:
		_play_animation("idle")

func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	target_player = body
	player_in_attack_range = true
	attack_timer = 0.0
	velocity.x = 0.0

func _on_attack_area_body_exited(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	player_in_attack_range = false
	if target_player != null and is_instance_valid(target_player):
		_play_animation("run")
	else:
		_play_animation("idle")

func _damage_player() -> void:
	if target_player == null or not is_instance_valid(target_player):
		return

	var player_health = target_player.get_node_or_null("Health")
	if player_health != null:
		player_health.call("take_damage", attack_damage)

func _on_health_died() -> void:
	is_dead = true
	_align_animation_to_collider("die")
	set_physics_process(false)
	velocity = Vector2.ZERO
	$Sight.set_deferred("monitoring", false)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$AttackArea.set_deferred("monitoring", false)
	$AttackArea/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	await animated_sprite_2d.animation_finished

	if golden_key_scene != null:
		var dropped_key := golden_key_scene.instantiate() as Area2D
		if dropped_key != null:
			get_parent().add_child(dropped_key)
			dropped_key.global_position = global_position
	else:
			push_error("На Minotaur-от не му е доделена сцената golden_key.tscn.")

	queue_free()
