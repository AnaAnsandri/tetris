extends Node

var current_tetromino
@onready var board = $"../Board" as Board
func _ready():
	current_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, null)
	board.tetronimo_bloqueado.connect(on_tetronimo_locked)
	
func on_tetronimo_locked():
	var new_tetronimo = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(new_tetronimo, false, null)
	
