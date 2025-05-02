extends Node2D

class_name sombra

@onready var escena = preload("res://Escenas/piece.tscn")
@onready var textura = preload("res://assets/Ghost.png")
var data: Resource

func _ready() -> void:
	var celdas =  Shared.cells [data.tetromino_type]
	for celda in celdas:
		var pieza = escena.instantiate() as Piece
		add_child(pieza)
		pieza.set_texture(textura)
		pieza.position = celda * pieza.get_size()
		pass
		
func set_sombra(nuevaPosicion: Vector2, piezaPosicion):
	global_position = nuevaPosicion
	var piezas = get_children()
	for i in piezas.size():
		piezas[i].position = piezaPosicion[i]
