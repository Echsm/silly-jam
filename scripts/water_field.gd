extends Node2D



class Particle:
	var position: Vector2
	var lifetime: float
	var tail: PackedVector2Array
var particles: Array[Particle]


@export var defaultFlow: Vector2 = Vector2.RIGHT
var currentFlow: PackedVector2Array
var fieldSize = Vector2i(49,28) # 16+1; 9+1
#var fieldSize = Vector2i(17,10) # 16+1; 9+1




func idxToPos(idx: int) -> Vector2:
	var idxVec: Vector2 = Vector2(idx % fieldSize.x, (idx - idx % fieldSize.x) / fieldSize.y)
	return Vector2(SizePerVector.x * idxVec.x ,  SizePerVector.y * idxVec.y)

func PosToClosestIdx(pos: Vector2) -> int:
		var UpperY = int(pos.y - fmod(pos.y, SizePerVector.y))
		var LowerY = int(pos.y - fmod(pos.y, SizePerVector.y)+SizePerVector.y)
		
		var LeftX = int(pos.x - fmod(pos.x, SizePerVector.x))
		var RightX = int(pos.x - fmod(pos.x, SizePerVector.x) + SizePerVector.x)

		var Idxes
		if abs(UpperY - pos.y) < abs(LowerY - pos.y):
			if abs(LeftX - pos.x) < abs(RightX - pos.x):
				Idxes = Vector2i(LeftX / SizePerVector.x , UpperY / SizePerVector.y)
			else:
				Idxes = Vector2i(RightX / SizePerVector.x , UpperY / SizePerVector.y)
		else:
			if abs(LeftX - pos.x) < abs(RightX - pos.x):
				Idxes = Vector2i(LeftX / SizePerVector.x , LowerY / SizePerVector.y)
			else:
				Idxes = Vector2i(RightX / SizePerVector.x , LowerY / SizePerVector.y)
		return Idxes.x + Idxes.y * fieldSize.x

	
func PosToIdx(pos: Vector2) -> int: #OBERE LINKE ECKE
	#var ToGrid = Vector2i(int(pos.x - fmod(pos.x, fieldSize.x)),int(pos.y - fmod(pos.y, fieldSize.y)))
	var ToGrid = Vector2i(int(pos.x - fmod(pos.x, SizePerVector.x)),int(pos.y - fmod(pos.y, SizePerVector.y)))
	var Idxes = Vector2i(ToGrid.x / SizePerVector.x , ToGrid.y / SizePerVector.y)
	return Idxes.x + Idxes.y * fieldSize.x

func getVelocity(pos: Vector2) -> Vector2:
	var v00 =  getFlowSafe(PosToIdx(pos))
	var v10 =  getFlowSafe(PosToIdx(pos) + 1)
	var v01 =  getFlowSafe(PosToIdx(pos) + fieldSize.x)
	var v11 =  getFlowSafe(PosToIdx(pos) + 1 + fieldSize.x)
	var tx = fmod(pos.x, SizePerVector.x) / SizePerVector.x
	var ty = fmod(pos.y, SizePerVector.y) / SizePerVector.y
	var top = v00.lerp(v10, tx)
	var bottom = v01.lerp(v11, tx)
	var flow = top.lerp(bottom, ty)
	return flow

func getCurl(pos: Vector2) -> float:
	var f00 =  getCurlSafe(PosToIdx(pos))
	var f10 =  getCurlSafe(PosToIdx(pos) + 1)
	var f01 =  getCurlSafe(PosToIdx(pos) + fieldSize.x)
	var f11 =  getCurlSafe(PosToIdx(pos) + 1 + fieldSize.x)
	var tx = fmod(pos.x, SizePerVector.x) / SizePerVector.x
	var ty = fmod(pos.y, SizePerVector.y) / SizePerVector.y
	var top = f00 * (1-tx) + f10 * tx
	var bottom = f01 * (1-tx) + f11 * tx
	var curl = top * (1-ty) + bottom * ty
	return curl

var lastMousePositions: PackedVector2Array
const waterBackToNormalSpeed: float = 0.01
var arrows: Array[Sprite2D]
var SizePerVector

func _ready() -> void:
	SizePerVector = Vector2(get_window().size.x / (fieldSize.x-1) , get_window().size.y / (fieldSize.y-1))

	for y in range(fieldSize.y):
		for x in range(fieldSize.x):
			currentFlow.append(Vector2.LEFT * 10)

func getFlowSafe(idx: int) -> Vector2:
	if idx < 0:
		return Vector2.ZERO
	elif idx >= len(currentFlow):
		return Vector2.ZERO
	else:
		return currentFlow.get(idx)

func getCurlSafe(idx: int) -> float:
	if idx < 0 or idx >= len(currentFlow):
		return 0.0
		
	var result = 0.0
	var flow = currentFlow.get(idx)
	
	result += Vector2.DOWN.cross(flow - currentFlow.get(idx+1))
	result += Vector2.UP.cross(flow - currentFlow.get(idx-1))
	result += Vector2.RIGHT.cross(flow -currentFlow.get(idx+fieldSize.y))
	result += Vector2.LEFT.cross(flow-currentFlow.get(idx-fieldSize.y))
	return -result
	
func getDivergenceSafe(idx: int) -> float:
	if idx < 0 or idx >= len(currentFlow):
		return 0.0
		
	var result = 0.0
	var flow = currentFlow.get(idx)
	
	result += Vector2.DOWN.dot(flow - currentFlow.get(idx+1))
	result += Vector2.UP.dot(flow - currentFlow.get(idx-1))
	result += Vector2.RIGHT.dot(flow -currentFlow.get(idx+fieldSize.y))
	result += Vector2.LEFT.dot(flow-currentFlow.get(idx-fieldSize.y))
	return result


func _draw():
	
	if Input.is_action_pressed("RightMouseButton"):
		for x in range(fieldSize.x):
			for y in range(fieldSize.y):
				var base := Vector2(x * SizePerVector.x,y * SizePerVector.y)
				var flow := getFlowSafe(x+y*fieldSize.x)
				draw_line(base, base + flow.normalized() * 10, Color.WHITE, flow.length())
				draw_line(base, base - flow.normalized() * 10 ,Color.WHITE, flow.length() *1.5)
	for p in particles:
		draw_polyline(p.tail, Color.DEEP_SKY_BLUE)
	
	

var c = 0

var mouseVel
func _input(event):
	if event is InputEventMouseMotion:
		mouseVel = event.velocity
	
var max = 0.0
func _process(delta: float) -> void:
	
	queue_redraw()
	
	var par = Particle.new()
	par.lifetime = randf() + 1.0
	par.position = Vector2(randf() * get_window().size.x, randf() * get_window().size.y)
	particles.append(par)
	if particles[0].lifetime < 0.0:
		particles.pop_front()
	for p in particles:
		
		
		p.lifetime -= delta
		if p.tail.size() > 5:
			p.tail.remove_at(0)
		p.tail.append(p.position)
		var c = getCurl(p.position)
		var v = getVelocity(p.position)
		var tangent = Vector2(-v.y, v.x).normalized()
		v += tangent * c * 0.2

		p.position += v * delta * 50


	for x in range(fieldSize.x):
		for y in range(fieldSize.y):
			if currentFlow[x+y*fieldSize.x].length() < 2.0:
				currentFlow[x+y*fieldSize.x] = Vector2.ZERO
				pass
			else:
				currentFlow[x+y*fieldSize.x] *= exp(-currentFlow[x+y*fieldSize.x].length() * 0.05 * delta);
			pass
	if Input.is_action_pressed("LeftMouseButton"):

		var mousePos: Vector2 = get_viewport().get_mouse_position()
		lastMousePositions.append(mousePos)
		
		if len(lastMousePositions) > 2:
			var i = PosToClosestIdx(mousePos)
			var target: Vector2 = (lastMousePositions[-1] - lastMousePositions[-2]).limit_length(100)

			var ang: float = (lastMousePositions[-1] - lastMousePositions[-2]).angle_to(lastMousePositions[-2] - lastMousePositions[-3])
			var prod: = (target * delta * 75).rotated(-ang * 2)
			
			if (lastMousePositions[-1].distance_to(lastMousePositions[-2])) > SizePerVector.x * 5:
				applyProd(i,prod)
				applyProd(PosToClosestIdx((lastMousePositions[-2]-mousePos)* 0.5 + mousePos),prod)
			else:
				applyProd(i,prod)


	if Input.is_action_just_released("LeftMouseButton"):
		lastMousePositions.clear()

func applyProd(i: int, prod: Vector2):
	currentFlow[i] += prod * 0.2
	
	currentFlow[i+1] += prod * 0.1
	currentFlow[i-1] += prod * 0.1
	currentFlow[i+fieldSize.x] += prod * 0.1
	currentFlow[i-fieldSize.x] += prod * 0.1
	
	currentFlow[i+2] += prod * 0.05
	currentFlow[i-2] += prod * 0.05
	currentFlow[i+fieldSize.x * 2] += prod * 0.05
	currentFlow[i-fieldSize.x * 2] += prod * 0.05

	currentFlow[i+1+fieldSize.x] += prod * 0.05
	currentFlow[i-1+fieldSize.x] += prod * 0.05
	currentFlow[i+fieldSize.x-1] += prod * 0.05
	currentFlow[i-fieldSize.x-1] += prod * 0.05
