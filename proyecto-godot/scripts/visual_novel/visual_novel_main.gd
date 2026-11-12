# Es el Main principal de la Novela Visual.
# Se encarga de capturar los controles por teclado

extends Control

# imports o preloads
const LectorCSVScript = preload("res://scripts/visual_novel/lector_csv.gd")
const RenderizadorUIScript = preload("res://scripts/visual_novel/renderizador_ui.gd")

@onready var lector_csv: LectorCSVScript = $GestorDatos as LectorCSVScript
@onready var renderizador_ui: RenderizadorUIScript = $RenderizadorUI as RenderizadorUIScript

# Variables globales
var guion: Array[Dictionary] = []
var indice_actual: int = 0
const RUTA_TEST_CSV: String = "res://data/dialogues/test.csv" # Ahora mismo es el unico csv que reconoce

func _ready() -> void:
	
	# --- HACK TEMPORAL DE QA ---
	var ruta_a_cargar: String = RUTA_TEST_CSV
	
	# Si venimos del menú de debug y hay una ruta guardada, la sobrescribimos
	if DebugData.ruta_csv_seleccionada != "":
		ruta_a_cargar = DebugData.ruta_csv_seleccionada
	# ---------------------------
	
	guion = lector_csv.procesar_csv(ruta_a_cargar)
	
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
		
# Para los eventos como la tecla espacio/enter/clic del raton 
func _unhandled_input(event: InputEvent) -> void:
	var es_espacio_o_enter: bool = event.is_action_pressed("ui_accept")
	
	# Detecta si es un clic izquierdo del ratón
	var es_clic_izquierdo: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	
	if es_espacio_o_enter or es_clic_izquierdo:
		gestionar_avance_interactivo()

func gestionar_avance_interactivo() -> void:
	# Evaluamos el estado público del renderizador
	if renderizador_ui.escribiendo:
		# Si está escribiendo, forzamos el autocompletado de la línea actual
		renderizador_ui.completar_texto_instantaneamente()
	else:
		# Si ya ha terminado de escribir, pasamos al siguiente diálogo
		avanzar_dialogo()
		
# FUnciones auxiliares para avanzar o retroceder
func avanzar_dialogo() -> void:
	if indice_actual < guion.size() - 1:
		indice_actual += 1
		renderizador_ui.renderizar_pantalla(guion[indice_actual])

func retroceder_dialogo() -> void:
	if indice_actual > 0:
		indice_actual -= 1
		renderizador_ui.renderizar_pantalla(guion[indice_actual])
