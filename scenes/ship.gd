extends RigidBody2D

@onready var water: Node = $"../WaterField"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var force : Vector2 =  water.getFlowAtPosition(position) * 3
	print(force)
	apply_central_force(force)
	pass
