extends RigidBody2D

@onready var water: Node = $"../WaterField"

@export var targetDirection: Vector2 = Vector2.RIGHT
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var Waterforce : Vector2 =  water.getFlowAtPosition(position)
	var RowForce : Vector2 = Vector2.from_angle(rotation) * 5
	var SailForce : Vector2 = Vector2.ZERO
	
	var Forces : Vector2 = Waterforce + RowForce + SailForce
	
	var steerTorque : float = -targetDirection.cross(Forces) * 10
	var keelTorque : float = Vector2.from_angle(rotation).cross(Forces) * 10
	var CurlTorque : float = water.getCurl(position) * 100
	
	print(keelTorque)
	
	var Torques : float = steerTorque
	apply_torque(Torques)
	apply_central_force(Waterforce + RowForce)
	
