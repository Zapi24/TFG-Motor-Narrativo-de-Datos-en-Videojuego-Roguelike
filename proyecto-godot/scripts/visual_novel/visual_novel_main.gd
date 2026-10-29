# Es el Main principal de la Novela Visual.
# Se encarga de capturar los controles por teclado

extends Control

# imports o preloads
const LectorCSVScript = preload("res://scripts/visual_novel/lector_csv.gd")
const RenderizadorUIScript = preload("res://scripts/visual_novel/renderizador_ui.gd")

@onready var lector_csv: LectorCSVScript = $GestorDatos
@onready var renderizador_ui: RenderizadorUIScript = $GestorUI

# Variables globales
var guion: Array[Dictionary] = []
var indice_actual: int = 0
const RUTA_TEST_CSV: String = "res://data/dialogues/test.csv" # Ahora mismo es el unico csv que reconoce

func _ready() -> void:
	guion = lector_csv.procesar_csv(RUTA_TEST_CSV)
	
	if not guion.is_empty():
		renderizador_ui.renderizar_pantalla(guion[indice_actual])
	else:
		printerr("ERROR CRÍTICO: El guion está vacío o el archivo no existe.")
		
func _process(_delta: float) -> void:
	# Captura de entrada bidireccional para pruebas Alpha
	if Input.is_action_just_pressed("ui_right"):
		avanzar_dialogo()
	elif Input.is_action_just_pressed("ui_left"):
		retroceder_dialogo()
		
# FUnciones auxiliares para avanzar o retroceder
func avanzar_dialogo() -> void:
	if indice_actual < guion.size() - 1:
		indice_actual += 1
		renderizador_ui.renderizar_pantalla(guion[indice_actual])

func retroceder_dialogo() -> void:
	if indice_actual > 0:
		indice_actual -= 1
		renderizador_ui.renderizar_pantalla(guion[indice_actual])
