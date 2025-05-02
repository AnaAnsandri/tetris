extends Node

var proximaPieza
var current_tetromino
@onready var board = $"../Board" as Board
@onready var ui: CanvasLayer = $"../UI"
var perdisteBolean = false
func _ready():
	current_tetromino = Shared.Tetromino.values().pick_random()
	proximaPieza = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(proximaPieza, true, Vector2(65, 55))
	board.tetronimo_bloqueado.connect(on_tetronimo_locked)
	board.perdiste.connect(perdisteFunc)
	
func on_tetronimo_locked():
	if perdisteBolean:
		return
	current_tetromino = proximaPieza
	proximaPieza = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(proximaPieza, true, Vector2(65, 55))
	
func perdisteFunc():
	perdisteBolean = true
	ui.perder()
	pass


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
