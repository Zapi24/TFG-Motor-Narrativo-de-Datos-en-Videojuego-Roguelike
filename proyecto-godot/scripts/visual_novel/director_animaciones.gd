# Se encarga de gestionar todas las animaciones, fundidos y efectos de cámara
extends Node

@onready var telon_negro: ColorRect = $TelonNegro

# Variables globales para controlar el tiempo
var TIEMPO_TELON: float = 1.0 # Tiempo que tarda el fade in/out de la escena completa
var TIEMPO_IMAGEN_FONDO = 0.8 # Tiempo quie tarda el crossfade de una imagen de fondo por otra


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
	
# Crossfase: vamos a ir haciendo desaparecer la imagen de fondo antigua al mismo tiempo que mostramos la nueva.
func crossfade_imagen_fondo(nueva_imagen: TextureRect) -> void:
	# Nos aseguramos de que la nueva imagen aparezca invisible
	nueva_imagen.modulate.a = 0.0
	nueva_imagen.show() 
	
	var tween = create_tween()
	tween.tween_property(nueva_imagen, "modulate:a", 1.0, TIEMPO_IMAGEN_FONDO).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
