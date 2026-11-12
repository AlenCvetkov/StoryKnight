extends AnimatableBody2D

@export var travel_distance: float = 60.0
@export var travel_speed: float = 60.0

var _start_x: float
var _direction: float = 1.0

func _ready() -> void:
	_start_x = position.x
	sync_to_physics = true

func _physics_process(delta: float) -> void:
	var left_limit := _start_x - travel_distance
	var right_limit := _start_x + travel_distance
	var next_x := position.x + _direction * travel_speed * delta

	if next_x >= right_limit:
		next_x = right_limit
		_direction = -1.0
	elif next_x <= left_limit:
		next_x = left_limit
		_direction = 1.0

	position.x = next_x
