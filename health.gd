# health.gd
extends Node

signal health_changed(current_health)
signal died

@export var max_health: int = 100
var current_health: int

@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health)
	if current_health == 0:
		die()

func die() -> void:
	died.emit()
	if animated_sprite_2d.sprite_frames.has_animation("die"):
		animated_sprite_2d.play("die")
