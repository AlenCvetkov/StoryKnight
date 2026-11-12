extends Area2D

@export var destination_path: NodePath

var _busy := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _busy or not body.is_in_group("player"):
		return

	if not GameState.door_unlocked:
		if not GameState.has_golden_key:
			print("Вратата е заклучена. Најди го златниот клуч.")
			return

		GameState.has_golden_key = false
		GameState.door_unlocked = true
		print("Вратата е отклучена со златниот клуч.")

	var destination := get_node_or_null(destination_path) as Area2D
	if destination == null:
		push_error("Не е поставена дестинација за вратата: " + name)
		return

	var exit_point := destination.get_node_or_null("ExitPoint") as Marker2D
	if exit_point == null:
		push_error("Не е најден ExitPoint кај дестинациската врата: " + destination.name)
		return

	_busy = true
	if body is CharacterBody2D:
		body.velocity = Vector2.ZERO
	body.global_position = exit_point.global_position
	print("Играчот помина низ %s и пристигна кај %s." % [name, destination.name])
	await get_tree().physics_frame
	_busy = false
