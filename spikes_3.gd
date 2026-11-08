extends Area2D

var player_inside = null


@onready var spike_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spike_collision: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	spike_sprite.frame_changed.connect(_sync_collision)
	_sync_collision()

func _sync_collision() -> void:
	spike_collision.set_deferred("disabled", spike_sprite.frame != 3)


func _on_body_entered(body):
	if body.name == "Player":
		player_inside = body
		player_inside.get_node("Health").take_damage(20)
				

func _on_body_exited(body: Node2D) -> void:
	print("Body Entered1")
	if body == player_inside:
		player_inside = null
