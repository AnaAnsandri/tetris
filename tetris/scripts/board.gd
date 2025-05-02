extends Node
class_name Board
signal tetronimo_bloqueado
signal perdiste
@onready var panel_container = $"../PanelContainer"
const ROW_COUNT = 20
const COLUMN_COUNT = 10
var proximaPieza
@export var tetromino_escena : PackedScene
var tetrominos: Array[Tetromino] = []

func spawn_tetromino(type: Shared.Tetromino, is_next_piece, spawn_position):
	panel_container = $"../PanelContainer"
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_escena.instantiate() as Tetromino
	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece
	if is_next_piece == false:
		tetromino.position = tetromino_data.spawn_position
		tetromino.other_tetrominos = tetrominos
		tetromino.lock_tetromino.connect(on_tetromino_lock)
		add_child(tetromino)
	else:
		tetromino.scale = Vector2(0.5, 0.5)
		panel_container.add_child(tetromino)
		tetromino.set_position(spawn_position)
		proximaPieza = tetromino
		
func on_tetromino_lock(tetronimo: Tetromino):
	proximaPieza.queue_free()
	tetrominos.append(tetronimo)
	verificarPerder()
	tetronimo_bloqueado.emit()
	lineachau()
	
func verificarPerder():
	for tetromino in tetrominos:
		var piezas = tetromino.get_children().filter(func (c): return c is Piece)
		for pieza in piezas:
			if pieza.global_position.y == -456:
				perdiste.emit()

func lineachau():
	var board_pieces = fill_board_pieces()
	clear_board_pieces(board_pieces)
	
func fill_board_pieces():
	var board_pieces = []
	
	for i in ROW_COUNT:
		board_pieces.append([])
		
	for tetromino in tetrominos:
		
		var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece )
		for piece in tetromino_pieces:
			var row = (piece.global_position.y + piece.get_size().y /2) / piece.get_size().y + ROW_COUNT/2
			board_pieces [row -1].append(piece) 
	return board_pieces
	
func clear_board_pieces(board_pieces):
	var i = ROW_COUNT
		
	while i > 0:
		var row_to_analyze = board_pieces[i - 1]
			
		if row_to_analyze.size() ==COLUMN_COUNT:
			chau_fila(row_to_analyze)
			board_pieces[i - 1].clear()
			move_all_row_pieces_down(board_pieces, i)
		i -= 1
			
func move_all_row_pieces_down(board_pieces, cleared_row_number):
	for i in range (cleared_row_number -1, 1, -1):
		var row_to_move = board_pieces[i - 1]
		if row_to_move.size() == 0:
			return false
		for piece in row_to_move:
			piece.position.y += piece.get_size().y
			board_pieces[cleared_row_number -1].append(piece)
		board_pieces[i - 1].clear()
	
func chau_fila(fila):
	for piece in fila:
		piece.queue_free()
