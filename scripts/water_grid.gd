extends Node2D

class FluidGridVisualiser:
	var grid: FluidGrid
	var cellDisplaySize: Vector2
	var boundsSize : Vector2
	var bottomLeft : Vector2
	var halfCellSize : float 
	var cellBorderThickness: int = 1
	var cellSizeMult = 64
	func _init(Grid: FluidGrid):
		self.grid = Grid
		self.cellDisplaySize =  Vector2(1,1) * grid.CellSize * (1-cellBorderThickness)
		self.boundsSize = Vector2(grid.CellCountX, grid.CellCountY) * grid.CellSize * cellSizeMult
		self.bottomLeft = Vector2(100,200)
		self.halfCellSize = grid.CellSize * cellSizeMult/ 2.0
	
	func CellCentre(x: int, y:int) -> Vector2:
		return bottomLeft + Vector2(x + 0.5, y+ 0.5) * grid.CellSize * cellSizeMult
	
	func CellCorner(x: int, y: int) -> Vector2:
		return bottomLeft + Vector2(x, y) * grid.CellSize * cellSizeMult

	func LeftEdgeCentre(x: int, y:int) -> Vector2:
		return CellCentre(x, y) - Vector2(halfCellSize,0)

	func BottomEdgeCentre(x: int, y:int) -> Vector2:
		return CellCentre(x, y) - Vector2(0,halfCellSize)
 
class FluidGrid:
	var CellCountX : int
	var CellCountY : int
	var CellSize: float
	var density : float = 1000.0
	var VelocitiesX: Array[Array]
	var VelocitiesY: Array[Array]
	
	var PressureMap: Array[Array]
	func _init(cellCountX: int, cellCountY: int, cellSize: float):
		self.CellCountX = cellCountX
		self.CellCountY = cellCountY
		self.CellSize = cellSize
		
		for x in range(cellCountX):
			PressureMap.append([])
			for y in range(cellCountY):
				PressureMap[x].append(0.0)		
		for x in range(cellCountX +1):
			VelocitiesX.append([])
			for y in range(cellCountY):
				VelocitiesX[x].append(randf() * 10 -5)
	
		for x in range(cellCountX):
			VelocitiesY.append([])
			for y in range(cellCountY+1):
				VelocitiesY[x].append(randf() * 10 -5)
	
	func CalculateVelocityDivergenceAtCell(cellX: int, cellY: int) -> float:
		var velocityTop : float = VelocitiesY[cellX + 0][cellY + 1]
		var velocityLeft : float = VelocitiesX[cellX + 0][cellY + 0]
		var velocityRight : float = VelocitiesX[cellX + 1][cellY + 0]
		var velocityBottom : float = VelocitiesY[cellX + 0][cellY + 0]
		
		var gradientX: float = (velocityRight - velocityLeft) / CellSize
		var gradientY: float = (velocityTop - velocityBottom) / CellSize
		
		var divergence: float = gradientX + gradientY
		return divergence
	
	func GetPressure(x : int, y: int) -> float:
		if x < 0 or  x >= CellCountX or y < 0 or y >= CellCountY:
			return 0.0
		return PressureMap[x][y]

	func PressureSolveCell(x: int, y: int) -> void:
		var pressureTop	 : float = GetPressure(x, y + 1)
		var pressureLeft: float = GetPressure(x -1, y)
		var pressureRight: float = GetPressure(x +1, y)
		var pressureBottom: float = GetPressure(x, y-1)
		var velocityTop  : float = VelocitiesY[x][y+1]
		var velocityLeft : float = VelocitiesX[x][y]
		var velocityRight : float = VelocitiesX[x+1][y]
		var velocityBottom: float = VelocitiesY[x][y]
		
		var pressureSum = pressureTop + pressureLeft + pressureRight + pressureBottom
		var deltaVelocitySum = velocityRight - velocityLeft + velocityTop - velocityBottom
		PressureMap[x][y] = (pressureSum - density * CellSize * deltaVelocitySum / (1.0/60.0) /4.0)
		
		
		
		
		
# Called when the node enters the scene tree for the first time.


var grid: FluidGrid
var visualizer :FluidGridVisualiser
func _ready() -> void:
	grid = FluidGrid.new(5,3,1)
	visualizer = FluidGridVisualiser.new(grid)
	pass # Replace with function body.

func _draw() -> void:
	for x in range(grid.CellCountX):
		for y in range(grid.CellCountY):
			var divergence: float = grid.CalculateVelocityDivergenceAtCell(x,y)
			var pressure: float = grid.GetPressure(x,y)
			var pressureT: float = absf(pressure)
			var divergenceT: float = absf(divergence)
			var colV = lerp(Color.BLACK, Color.BLUE if  pressure > 0 else Color.RED, pressureT)
			draw_rect(Rect2(visualizer.CellCorner(x,y), Vector2(grid.CellSize,grid.CellSize)),colV,true)
			draw_string(ThemeDB.fallback_font,visualizer.LeftEdgeCentre(x,y),str(snapped(pressure,0.01)))
			draw_string(ThemeDB.fallback_font,visualizer.LeftEdgeCentre(x,y)+Vector2.DOWN* 30,str(snapped(divergence,0.01)))

	for x in range(len(grid.VelocitiesX)):
		for y in range(len(grid.VelocitiesX[0])):
			draw_line(visualizer.LeftEdgeCentre(x,y),visualizer.LeftEdgeCentre(x,y) + Vector2.RIGHT * grid.VelocitiesX[x][y],Color.GREEN, 3)
	
	for x in range(len(grid.VelocitiesY)):
		for y in range(len(grid.VelocitiesY[0])):
			draw_line(visualizer.BottomEdgeCentre(x,y),visualizer.BottomEdgeCentre(x,y) + Vector2.UP * grid.VelocitiesY[x][y],Color.GREEN, 3)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(grid.CalculateVelocityDivergenceAtCell(0,0))
	if Input.is_action_just_pressed("LeftMouseButton"):
		var mousePos: Vector2 = get_viewport().get_mouse_position()
		print(mousePos)
		var x = (int(((mousePos.x-visualizer.bottomLeft.x)/(grid.CellSize * visualizer.cellSizeMult))))
		var y = (int(((mousePos.y-visualizer.bottomLeft.y)/(grid.CellSize * visualizer.cellSizeMult))))
		grid.PressureSolveCell(x,y)
	queue_redraw()
