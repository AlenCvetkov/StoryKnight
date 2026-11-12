extends CharacterBody2D

@export var speed = 180
@export var jump_velocity = -400
var is_attacking: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var hitbox_offset: Vector2
var spaw_position: Vector2 

func _ready() -> void:
	hitbox_offset = hitbox.position
	spaw_position = global_position
	$Health.died.connect(_on_player_died)

func _physics_process(delta):
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	if not is_attacking:
		process_movement(delta)
		process_animation()
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		var attack_dir = -1 if animated_sprite.flip_h else 1
		velocity.x = attack_dir * (speed * 0.2)
		
	_update_hitbox_offset()
	move_and_slide()

func process_movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction = Input.get_axis("left", "right")
	velocity.x = direction * speed

func process_animation():
	var direction = Input.get_axis("left", "right")
	if velocity.y < 0.0 and (not is_on_floor() or Input.is_action_just_pressed("jump")):
		if animated_sprite.animation != &"jump_start":
			animated_sprite.play("jump_start")
		return
	if not is_on_floor():
		var air_animation: StringName = &"jump_fall"
		if animated_sprite.animation != air_animation:
			animated_sprite.play(air_animation)
		return
	
	if direction != 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("idle")

func _update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	if animated_sprite.flip_h:
		hitbox.position = Vector2(x-20, y)
	else:
		hitbox.position = Vector2(x, y)

func attack() -> void:
	is_attacking = true
	var attack_animations: Array[StringName] = [&"attack", &"attack2"]
	var chosen_attack: StringName = attack_animations.pick_random()

	if not animated_sprite.sprite_frames.has_animation(chosen_attack):
		push_error("Не постои анимацијата: " + String(chosen_attack))
		is_attacking = false
		return

	animated_sprite.play(chosen_attack)
	
	# Чекаме мал дел од секундата (додека се отвора замавот од анимацијата)
	await get_tree().create_timer(0.1).timeout
	
	# Проверуваме кои тела се во моментов допирна точка со хитбоксот
	var overlapping_bodies = hitbox.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("enemy_monster"):
			var enemy_health = body.get_node_or_null("Health")
			if enemy_health != null:
				if body.has_method("apply_knockback"):
					body.call("apply_knockback", global_position)
				enemy_health.take_damage(25)
				print("Hit enemyMonster")

	# Чекаме да заврши целата анимација до крај
	await animated_sprite.animation_finished
	is_attacking = false
	
func _on_player_died() -> void:
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	animated_sprite.play("dead")
	await animated_sprite.animation_finished
	
	global_position = spaw_position
	var player_health = $Health
	player_health.current_health = player_health.max_health
	player_health.health_changed.emit(player_health.current_health)
	
	animated_sprite.play("idle")
	set_physics_process(true)
	
