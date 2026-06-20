extends Node2D

@export var defaultFlow: Vector2 = Vector2.RIGHT.normalized()
var currentFlow: PackedVector2Array
var fieldSize = Vector2i(16,9)

var lastMousePositions: PackedVector2Array
const waterBackToNormalSpeed: float = 0.01

var arrows: Array[Sprite2D]

var SizePerVector

func _ready() -> void:
	SizePerVector = Vector2(get_window().size.x / fieldSize.x , get_window().size.y / fieldSize.y)
	for i in range(fieldSize.x * fieldSize.y):
		currentFlow.append(Vector2.DOWN)
	
	for x in range(fieldSize.x):
		for y in range(fieldSize.y):
			var s = Sprite2D.new()
			@warning_ignore("integer_division")
			s.position = Vector2(x * SizePerVector.x + SizePerVector.x/2 , y * SizePerVector.y + SizePerVector.y/2)
			s.scale = Vector2(0.5, 0.5)
			s.texture = load("res://assets/arrowUp.svg")
			s.rotation = currentFlow[x+y*fieldSize.x].angle() + PI/2.0
			add_child(s)
			arrows.append(s)

func clampLength(v: Vector2, l: float) -> Vector2:
	if v.length() > l:
		return v.normalized() * l
	else:
		return v
func getFlowAtPosition(pos: Vector2) -> Vector2:
	var x_index = int(pos.x / (get_window().size.x/fieldSize.x))
	var y_index = int(pos.y / (get_window().size.y/fieldSize.y))
	var idx = y_index + x_index * fieldSize.y
	
	if idx >= len(currentFlow):
		return Vector2.ZERO
	else:
		return currentFlow[y_index + x_index * fieldSize.y]

func curlAtIdx(idx: int) -> float:
	var result = 0.0
	var flow
	var delta
	#DOWN
	flow = currentFlow[idx+1]
	delta = currentFlow[idx] - currentFlow[idx+1]
	result += Vector2.DOWN.cross(delta)
	
	#UP
	flow = currentFlow[idx-1]
	delta = currentFlow[idx] - currentFlow[idx-1]
	result += Vector2.UP.cross(delta)

	#RIGHT
	flow = currentFlow[idx+fieldSize.y]
	delta = currentFlow[idx] - currentFlow[idx+fieldSize.y]
	result += Vector2.RIGHT.cross(delta)
	
	flow = currentFlow[idx-fieldSize.y]
	delta = currentFlow[idx] - currentFlow[idx-fieldSize.y]
	result += Vector2.LEFT.cross(delta)
	return -result
				
func divergenceAtIdx(idx: int) -> float:
	var result = 0.0
	var flow
	var delta
	#DOWN
	flow = currentFlow[idx+1]
	delta = currentFlow[idx] - currentFlow[idx+1]
	result += Vector2.DOWN.dot(delta)
	
	#UP
	flow = currentFlow[idx-1]
	delta = currentFlow[idx] - currentFlow[idx-1]
	result += Vector2.UP.dot(delta)

	#RIGHT
	flow = currentFlow[idx+fieldSize.y]
	delta = currentFlow[idx] - currentFlow[idx+fieldSize.y]
	result += Vector2.RIGHT.dot(delta)
	
	flow = currentFlow[idx-fieldSize.y]
	delta = currentFlow[idx] - currentFlow[idx-fieldSize.y]
	result += Vector2.LEFT.dot(delta)
	return result
				
func getDivergence(pos: Vector2) -> float:
	return divergenceAtIdx(mapMousePositionToIndex(pos))

func getCurl(pos: Vector2) -> float:
	return curlAtIdx(mapMousePositionToIndex(pos))
func mapMousePositionToIndex(pos: Vector2) -> int:
	var x_index = int(pos.x / (get_window().size.x/fieldSize.x))
	var y_index = int(pos.y / (get_window().size.y/fieldSize.y))
	return y_index + x_index * fieldSize.y

func _process(_delta: float) -> void:
	#for i in range(len(currentFlow)): #Waterflow in richtung des Basisvektors ausrichten
#		var v: Vector2 = currentFlow[i]
	#	currentFlow[i] = (1.0-waterBackToNormalSpeed) * v + waterBackToNormalSpeed * defaultFlow # TODO ABHÄNGIG VON delta machen
	
	for i in range(len(currentFlow)): #Pfeile in richtige richtung Drehen
		arrows[i].rotation = currentFlow[i].angle() + PI/2.0
	
	

	if Input.is_action_just_pressed("RightMouseButton"):
		var idx: int = mapMousePositionToIndex(get_viewport().get_mouse_position())
		print("Flow\t" + str(currentFlow[idx]) + "\tStrength\t" + str(currentFlow[idx].length()) + "\tDivergence\t" + str(divergenceAtIdx(idx))+ "\tCurl\t" + str(curlAtIdx(idx)))
	
		
	if Input.is_action_pressed("LeftMouseButton"):
		var mousePos: Vector2 = get_viewport().get_mouse_position()
		lastMousePositions.append(mousePos)
		
		if len(lastMousePositions) > 1:
			var target: Vector2 = lastMousePositions[-1] - lastMousePositions[-2]
			currentFlow[mapMousePositionToIndex(mousePos)] =  clampLength(0.5 * target + 0.5 * currentFlow[mapMousePositionToIndex(mousePos)], 50.0)
			currentFlow[mapMousePositionToIndex(mousePos)] = target.normalized()
			#currentFlow[mapMousePositionToIndex(mousePos)+1] =  clampLength(0.5 * target + 0.5 * currentFlow[mapMousePositionToIndex(mousePos)], 50.0)
			#currentFlow[mapMousePositionToIndex(mousePos)-1] =  clampLength(0.5 * target + 0.5 * currentFlow[mapMousePositionToIndex(mousePos)], 50.0)
			#currentFlow[mapMousePositionToIndex(mousePos)+ fieldSize.y] =  clampLength(0.5 * target + 0.5 * currentFlow[mapMousePositionToIndex(mousePos)], 50.0)
			#currentFlow[mapMousePositionToIndex(mousePos)- fieldSize.y] =  clampLength(0.5 * target + 0.5 * currentFlow[mapMousePositionToIndex(mousePos)], 50.0)

	if Input.is_action_just_released("LeftMouseButton"):
		lastMousePositions.clear()

	
	
