extends RigidBody2D

@onready var water: Node = $"../WaterField"

@export var targetDirection: Vector2 = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var Waterforce : Vector2 = water.getVelocity(position)
	var RowForce : Vector2 = Vector2.from_angle(rotation) * 2
	var SailForce : Vector2 = Vector2.ZERO
	
	var Forces : Vector2 = RowForce +Waterforce
	
	var perp = Vector2(-Forces.y,Forces.x).normalized()
	Forces += perp * water.getCurl(position)
	
	
	var steerTorque : float = -targetDirection.cross(Vector2.from_angle(rotation) * Forces.dot(Vector2.from_angle(rotation))) * 40
	var keelTorque : float = Vector2.from_angle(rotation).cross(Forces) * 40
	var CurlTorque : float = - 25 * (water.getCurl(position))
	
	var Torques : float = steerTorque + keelTorque + CurlTorque
	apply_torque(Torques)
	apply_central_force(Forces)
	
