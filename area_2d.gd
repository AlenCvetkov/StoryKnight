extends Area2D

var player_inside = null
@onready var timer =  $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			child.play("move")
	
	timer.wait_time =0.5
	timer.one_shot = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body):
	if body.name == "Player":
		player_inside = body
		timer.start()

func _on_body_exited(body: Node2D) -> void:
	print("Body Entered1")
	if body == player_inside:
		player_inside = null
		timer.stop()


func _on_timer_timeout():
	if player_inside:
		player_inside.get_node("Health").take_damage(20)
