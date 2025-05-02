extends Node2D

class_name Tetromino
signal lock_tetromino(tetromino: Tetromino)

# [] para el copy paste

var bounds = {
	"min_x": -216,
	"max_x": 216,
	"max_y": 457
}
var tetromino_data
var is_next_piece
var pieces = []
var wall_kicks
var other_tetrominos: Array[Tetromino] = []
var rotacion_index = 0
var sombra 

@onready var timer = $Timer
@onready var pieceEscena = preload("res://Escenas/piece.tscn")
@onready var sombraEscena = preload("res://Escenas/sombra.tscn")
var tetromino_cells

func _ready():
	tetromino_cells = Shared.cells [tetromino_data.tetromino_type]
	
	for cell in tetromino_cells:
		var piece = pieceEscena.instantiate() as Piece
		pieces.append(piece)
		add_child(piece)
		piece.set_texture(tetromino_data.piece_texture)
		piece.position = cell * piece.get_size()
		
	if is_next_piece == false:
		position = tetromino_data.spawn_position
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz
		sombra = sombraEscena.instantiate() as sombra
		sombra.data = tetromino_data
		get_tree().root.add_child.call_deferred(sombra)
		dropSombra.call_deferred()
	else: 
		timer.stop()
		set_process_input(false)
func dropSombra():
	var posicionFinalDrop
	var updatePosicion = calculate_global_position(Vector2.DOWN, global_position)
	
	while updatePosicion != null:
		updatePosicion = calculate_global_position(Vector2.DOWN, updatePosicion)
		if updatePosicion != null:
			posicionFinalDrop = updatePosicion
	if posicionFinalDrop != null:
		var hijos = get_children().filter(func (c): return c is Piece)
		var piezasPosicion = []
		for i in hijos.size():
			piezasPosicion.append(hijos[i].position)
		sombra.set_sombra(posicionFinalDrop, piezasPosicion)
	return posicionFinalDrop
			
func _input(_event):
	if Input.is_action_just_pressed("izquierda"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("derecha"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("abajo"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("caida"):
		caidaBloque()
	elif Input.is_action_just_pressed("rotar_izquierda"):
		rotar_tetromino(-1)
	elif Input.is_action_just_pressed("rotar_derecha"):
		rotar_tetromino(1)
		
func move(direction: Vector2) -> bool: 
	var newPosition = calculate_global_position(direction, global_position)
	if newPosition: 
		global_position = newPosition
		if direction != Vector2.DOWN:
			dropSombra.call_deferred()
		return true
	return false
func calculate_global_position(direction: Vector2, starting_global_position: Vector2):
	if colliding_with_tetrominos(direction, starting_global_position):
		return null
	
	if !is_within_game_bounds(direction, starting_global_position):
		return null
	return starting_global_position + direction * pieces[0].get_size().x
	
func is_within_game_bounds(direction: Vector2, starting_global_position: Vector2):
	for piece in pieces:
		var new_position = piece.position + starting_global_position + direction * piece.get_size()
		if new_position.x < bounds.get("min_x") or new_position.x > bounds.get("max_x") or new_position.y >= bounds.get("max_y"):
			return false
	return true

	
func caidaBloque():
	while(move(Vector2.DOWN)):
		continue
	lock()
		
func lock():
	timer.stop()
	lock_tetromino.emit(self)
	set_process_input(false)
	sombra.queue_free()
	
func colliding_with_tetrominos(direction: Vector2, starting_global_position: Vector2):
	for tetromino in other_tetrominos:
		var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece )
		for tetromino_piece in tetromino_pieces:
			for piece in pieces:
				if starting_global_position + piece.position + direction * piece.get_size().x == tetromino.global_position + tetromino_piece.position:
					return true
	return false
	
func rotar_tetromino(direction: int):
	var original_rotacion_index = rotacion_index
	if tetromino_data.tetromino_type == Shared.Tetromino.O:
		return
	
	aplicar_rotacion(direction)
	rotacion_index = wrap(rotacion_index + direction,0 ,4)
	
	if !test_wall_kicks(rotacion_index,direction):
		rotacion_index = original_rotacion_index
		aplicar_rotacion(-direction)
	dropSombra.call_deferred()
	
func aplicar_rotacion(direction: int):
	var rotacionMatrix = Shared.clockwise_rotation_matrix if direction == 1 else Shared.counter_clockwise_rotation_matrix
	
	var tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	
	for i in tetromino_cells.size():
		var cell= tetromino_cells[i]
		var x
		var y
		var coordenadas = rotacionMatrix[0] * cell.x + rotacionMatrix[1] * cell.y
		tetromino_cells[i] = coordenadas
		
	for i in pieces.size():
		var piece = pieces[i]
		piece.position = tetromino_cells[i] * piece.get_size()
		
func test_wall_kicks(rotation_index: int, rotation_direction: int):
	var wall_kick_index = get_wall_kick_index(rotation_index, rotation_direction)
	
	for i in wall_kicks[0].size():
		var translation = wall_kicks[wall_kick_index][i]
		if move(translation):
			return true
	return false
	
func get_wall_kick_index(rotacion_index: int, rotacion_direccion):
	var wall_kick_index = rotacion_index * 2
	if rotacion_direccion < 0:
		wall_kick_index -= 1
	return wrap(wall_kick_index, 0, wall_kicks.size())

func _on_timer_timeout() -> void:
	var deberia_bloquearse = !move(Vector2.DOWN)
	if deberia_bloquearse:
		lock()
