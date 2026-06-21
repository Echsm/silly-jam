extends Node2D

var boats: Array[Node2D]
var cooldown: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func spawn_boat() -> void:
	var bt = preload("res://scenes/boat.tscn").instantiate()
	bt.position.x = 100
	bt.position.y = 100
	add_child(bt)
	boats.append(bt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(cooldown)
	cooldown -= delta
	if cooldown < 0 or len(boats) == 0:
		cooldown = 10
		spawn_boat()
		
	for boat in boats:
		if boat.position.x < -100 or boat.position.x > 1300 or boat.position.y < 0 or boat.position.y > 600 or boat.health < 0.0:
			boat.visible = false
	boats = boats.filter(func(node): return is_instance_valid(node))
	
