# Se encarga de gestionar todas las animaciones, fundidos y efectos de cámara
extends Node

@onready var telon_negro: ColorRect = $TelonNegro
@onready var efecto_shake: Camera2D = $EfectoShake
@onready var efecto_flash: ColorRect = $EfectoFlash

# Variables globales para controlar el tiempo
var TIEMPO_TELON: float = 1.0 # Tiempo que tarda el fade in/out de la escena completa
var TIEMPO_IMAGEN_FONDO = 0.8 # Tiempo quie tarda el crossfade de una imagen de fondo por otra
var TIEMPO_PERSONAJE_FUNDIDO: float = 0.25
var TIEMPO_PERSONAJE_SALTO: float = 0.15
var TIEMPO_PERSONAJE_DESLIZAMIENTO: float = 0.4

var TIEMPO_EFECTOS: float = 1.5
var INTENSIDAD_SHAKE: float = 30 # Para controlar la intensidad del shake


var DISTANCIA_PERSONAJE_DESLIZAMIENTO: float = 700.0 # Pixeles para salir completamente de la escena
var ALTURA_PERSONAJE_ELEVACION: float = 30.0 # Pequeña elevación vertical


var tween_indicador: Tween # Guardamos la referencia a la animación en bucle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Nos aseguramos de que el telón empiece completamente negro bloqueando la vista
	telon_negro.modulate.a = 1.0
	telon_negro.show()


# Fade in: El telón negro desaparece mostrando la escena
func fade_in_telon() -> void:
	telon_negro.show()
	var tween = create_tween()
	
	# Animamos la opacidad del telón de 1.0 a 0.0
	tween.tween_property(telon_negro, "modulate:a", 0.0, TIEMPO_TELON).set_trans(Tween.TRANS_SINE)
	
	
	await tween.finished # Esperamos a que la animación termine 
	telon_negro.hide()

# Fade out: El telón negro aparece mostrando la escena
func fade_out_telon() -> void:
	telon_negro.show()
	telon_negro.modulate.a = 0.0
	var tween = create_tween()
		
	# Animamos la opacidad del telón de 1.0 a 0.0
	tween.tween_property(telon_negro, "modulate:a", 1.0, TIEMPO_TELON).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	
# Crossfade: vamos a ir haciendo desaparecer la imagen de fondo antigua al mismo tiempo que mostramos la nueva.
func crossfade_imagen_fondo(nueva_imagen: TextureRect) -> void:
	# Nos aseguramos de que la nueva imagen aparezca invisible
	nueva_imagen.modulate.a = 0.0
	nueva_imagen.show() 
	
	var tween = create_tween()
	tween.tween_property(nueva_imagen, "modulate:a", 1.0, TIEMPO_IMAGEN_FONDO).set_trans(Tween.TRANS_SINE)
	
	await tween.finished

# Iniciar la animación del indicador en forma de flecha de saltar linea
func animar_indicador_siguiente(indicador: TextureRect) -> void:
	if indicador == null:
		return
		
	indicador.show()
	indicador.modulate.a = 0.8 
	
	if tween_indicador and tween_indicador.is_running():
		tween_indicador.kill()
		
	tween_indicador = create_tween().set_loops()
	tween_indicador.tween_property(indicador, "modulate:a", 0.3, 0.6).set_trans(Tween.TRANS_SINE)
	tween_indicador.tween_property(indicador, "modulate:a", 0.8, 0.6).set_trans(Tween.TRANS_SINE)

# Detener la animación del indicador en forma de flecha de saltar linea
func detener_indicador_siguiente(indicador: TextureRect) -> void:
	if indicador == null:
		return
		
	if tween_indicador and tween_indicador.is_running():
		tween_indicador.kill()
	indicador.hide()
	
# Animacio personaje: funcion para deslizar al personaje desde fuera o desde dentro de la animación	
func deslizar_personaje(personaje: TextureRect, entrada: bool) -> void:
	var pos_escena: Vector2 = personaje.position
	
	# Vemos si estamos ante una entrada o una salida
	var pos_fuera: Vector2
	if entrada: 
		pos_fuera = pos_escena + Vector2(-DISTANCIA_PERSONAJE_DESLIZAMIENTO, -ALTURA_PERSONAJE_ELEVACION)
		personaje.position = pos_fuera
	else:
		pos_fuera = pos_escena + Vector2(DISTANCIA_PERSONAJE_DESLIZAMIENTO, ALTURA_PERSONAJE_ELEVACION)
		personaje.position = pos_escena
		
	personaje.modulate.a = 1.0
	personaje.show()
	
	var tween = create_tween().set_parallel(true)
	
	if entrada:
		tween.tween_property(personaje, "position:x", pos_escena.x, TIEMPO_PERSONAJE_DESLIZAMIENTO).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(personaje, "position:y", pos_escena.y, TIEMPO_PERSONAJE_DESLIZAMIENTO).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(personaje, "position:x", pos_fuera.x, TIEMPO_PERSONAJE_DESLIZAMIENTO).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(personaje, "position:y", pos_fuera.y, TIEMPO_PERSONAJE_DESLIZAMIENTO).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	await tween.finished
	
	# Limpiamos al terminar
	if not entrada:
		personaje.hide()
		personaje.position = pos_escena # Lo devolvemos a su sitio original en secreto

# Animación personaje: hace un crossfade entre el personaje nuevo y el antiguo
func crossfade_personaje(personaje_antiguo: TextureRect, nuevo_personaje: TextureRect) -> void:
	personaje_antiguo.show()
	personaje_antiguo.modulate.a = 1.0
	
	nuevo_personaje.show()
	nuevo_personaje.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	
	# Hacmeos desaparecer el personaje
	tween.tween_property(personaje_antiguo, "modulate:a", 0.0, TIEMPO_PERSONAJE_FUNDIDO).set_trans(Tween.TRANS_SINE)
	
	# El personaje nuevo empieza a aparecer cuando el antiguo va por el 40%
	tween.tween_property(nuevo_personaje, "modulate:a", 1.0, TIEMPO_PERSONAJE_FUNDIDO).set_delay(TIEMPO_PERSONAJE_FUNDIDO * 0.4).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	personaje_antiguo.hide()
# Animación personaje: hace un pequeño salto entre la pose del antiguo personaje y el nuevo
func salto_personaje(personaje: TextureRect) -> void:
	var pos_original = personaje.position
	
	var tween = create_tween()
	# Sube
	tween.tween_property(personaje, "position:y", pos_original.y - 15.0, TIEMPO_PERSONAJE_SALTO).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Baja
	tween.tween_property(personaje, "position:y", pos_original.y, TIEMPO_PERSONAJE_SALTO).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# No le ponemos un await para que no congele el texto	
	
# Efecto flash de pantalla
func ejecutar_flash() -> void:
	efecto_flash.modulate.a = 1.0 # Empieza entero en blanco
	efecto_flash.show()
	
	var tween = create_tween()
	# Lo hacemos transparente
	tween.tween_property(efecto_flash, "modulate:a", 0.0, TIEMPO_EFECTOS).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	efecto_flash.hide()

# Efecto de sacudir la pantalla
func ejecutar_shake() -> void: 
	var tween = create_tween()
	
	# Cuantas veces va a sacudirse
	var sacudidas: float = 30.0
	var tiempo_por_sacudida: float = TIEMPO_EFECTOS / sacudidas
	
	for i in range(sacudidas):
		# Generamos coordenadas aleatorias entre la intensidad negativa y positiva 
		var aux = Vector2(randf_range(-INTENSIDAD_SHAKE, INTENSIDAD_SHAKE), randf_range(-INTENSIDAD_SHAKE, INTENSIDAD_SHAKE))
		tween.tween_property(efecto_shake, "offset", aux, tiempo_por_sacudida)
		
		# Devolvemos la cámara a su posicion central
		tween.chain().tween_property(efecto_shake, "offset", Vector2.ZERO, tiempo_por_sacudida)
		
		await tween.finished
	
	
	
