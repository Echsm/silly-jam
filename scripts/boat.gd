extends Node2D

@onready var water: Node = $"../../WaterField"

# Called when the node enters the scene tree for the first time.



var velocity: Vector2
var acceleration: Vector2
var rot_velocity: float
var rot_acceleration: float
var target_direction : Vector2 = Vector2.DOWN.normalized()
var rowingforce: float = 8.0
var keel_multiplier: float = 0.01
var health = 10.0
@export var drag: float = 8.0
@export var rot_drag: float = 1.0

@export var mass: float = 100.0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	
	
	#Water
	velocity += water.getVelocity(position) / mass
	#Rowing
	velocity += Vector2.from_angle(rotation) * rowingforce / mass
	
	velocity -= velocity * drag * delta


	#Steering
	rot_velocity += keel_multiplier * Vector2.from_angle(rotation).cross(velocity)
	
	#Keel
	
	#Curl
	rot_velocity += 0.1 * water.getCurl(position) / mass
#

	#Drag
	rot_velocity -= rot_velocity * rot_drag * delta
	
	if abs(rot_velocity) > 0.05:
		health -= rot_velocity

	
	position += velocity
	rotation += rot_velocity
	
	
	pass
