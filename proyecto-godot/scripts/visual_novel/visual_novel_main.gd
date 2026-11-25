# Es el Main principal de la Novela Visual.
# Se encarga de capturar los controles por teclado

extends Control

# imports o preloads
const LectorCSVScript = preload("res://scripts/visual_novel/lector_csv.gd")
const RenderizadorUIScript = preload("res://scripts/visual_novel/renderizador_ui.gd")

@onready var lector_csv: LectorCSVScript = $GestorDatos as LectorCSVScript
@onready var renderizador_ui: RenderizadorUIScript = $RenderizadorUI as RenderizadorUIScript
@onready var director_animaciones: Node = $DirectorAnimaciones
@onready var gestor_audio: Node = $GestorAudio

@onready var contenedor_ui: Panel = $ContenedorUI
@onready var boton_mute: Button = $ContenedorBotones/OrganizadorBotones/BotonMute
@onready var boton_ocultar: Button = $ContenedorBotones/OrganizadorBotones/BotonOcultar

@export var audio_on: Texture2D
@export var audio_off: Texture2D
@export var ojo_on: Texture2D
@export var ojo_off: Texture2D

# Variables globales
var guion: Array[Dictionary] = []
var indice_actual: int = 0
var ui_oculta: bool = false # Para saber si el cuadro de texto esta oculto o no
const RUTA_TEST_CSV: String = "res://data/dialogues/test.csv" # Ahora mismo es el unico csv que reconoce

func _ready() -> void:
	# Cargamos las funciones de pulsado de los botones
	boton_mute.pressed.connect(_on_boton_mute_pulsado)
	boton_ocultar.pressed.connect(_on_boton_ocultar_pulsado)
	
	_actualizar_icono_mute(false)
	_actualzar_icono_ocultar(false)
	
	# --- HACK TEMPORAL DE QA ---
	var ruta_a_cargar: String = RUTA_TEST_CSV
	
	# Si venimos del menú de debug y hay una ruta guardada, la sobrescribimos
	if DebugData.ruta_csv_seleccionada != "":
		ruta_a_cargar = DebugData.ruta_csv_seleccionada
	# ---------------------------
	
	guion = lector_csv.procesar_csv(ruta_a_cargar)
	
	if not guion.is_empty():
		await director_animaciones.fade_in_telon() # Ejecutamos la animación y esperamos
		renderizador_ui.renderizar_pantalla(guion[indice_actual])
	else:
		printerr("ERROR CRÍTICO: El guion está vacío o el archivo no existe.")
		
func _process(_delta: float) -> void:
	
	# Si el modo interfaz esta oculto, bloqueamos la navegación por teclado para que no siga avanzando
	if ui_oculta:
		return
	
	# Captura de entrada bidireccional para pruebas Alpha
	if Input.is_action_just_pressed("ui_right"):
		avanzar_dialogo()
	elif Input.is_action_just_pressed("ui_left"):
		retroceder_dialogo()
		
# Para los eventos como la tecla espacio/enter/clic del raton 
func _unhandled_input(event: InputEvent) -> void:
	
	# Si la interfaz esta oculta, ignoramos los clicks o la barra espaciadora
	if ui_oculta: 
		return
		
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
	else:
		# Si ya no hay más líneas en el array ejecutamos la animación de cerrar
		await cerrar_telon()

func retroceder_dialogo() -> void:
	if indice_actual > 0:
		indice_actual -= 1
		renderizador_ui.renderizar_pantalla(guion[indice_actual])
		
func cerrar_telon() -> void:
	# Dejamos que se pueda interactuar más con los inputs
	set_process_unhandled_input(false)
	set_process(false)
	await director_animaciones.fade_out_telon() # Ejecutamos la animación y 
	
	
# Logica de botontes de la interfaz en la pantalla superior izquierda
func _on_boton_mute_pulsado() -> void:
	var esta_muteado: bool = gestor_audio.alternar_mute_musica()
	_actualizar_icono_mute(esta_muteado)
	
func _actualizar_icono_mute(esta_muteado: bool) -> void:
	if esta_muteado:
		if audio_off:
			boton_mute.icon = audio_off
	else:
		if audio_on:
			boton_mute.icon = audio_on
			
func _on_boton_ocultar_pulsado() -> void:
	ui_oculta = not ui_oculta # Alternamos el valor que tuviese
	
	if ui_oculta :
		contenedor_ui.hide()
	else:
		contenedor_ui.show()
		
	_actualzar_icono_ocultar(ui_oculta)
		
func _actualzar_icono_ocultar(esta_oculto: bool) -> void:
	if esta_oculto:
		if ojo_off:
			boton_ocultar.icon = ojo_off
	else:
		if ojo_on:
			boton_ocultar.icon = ojo_on
