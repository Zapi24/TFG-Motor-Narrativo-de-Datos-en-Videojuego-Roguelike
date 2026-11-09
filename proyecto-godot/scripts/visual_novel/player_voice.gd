extends AudioStreamPlayer

const AUDIO: AudioStream = preload("res://assets/sounds/sonido_texto.ogg")

var random :=RandomNumberGenerator.new() # Objeto para crear numeros random

# Diccionario para los distintos tipos de voz
const TIPOS_VOZ = {
	"voz1":   { "tono_base": 1.1, "variacion": 0.05 }, # Voz un poco más aguda
	"voz2":  { "tono_base": 0.8, "variacion": 0.08 }, # Voz más grave y profunda
	"voz3": { "tono_base": 1.5, "variacion": 0.01 }, # Voz muy aguda y robótica (sin casi variación)
	"voz4": { "tono_base": 0.6, "variacion": 0.02 } # Voz muy grave de ultratumba
}

func reproducir_voz(voz: String) -> void:
	
	if AUDIO == null: # Por si no encontrase el audio.
		printerr("ERROR: No se ha podido acceder al sonido que se reproduce al avanzar el texto. ")
		return
		
	if stream != AUDIO:
		stream = AUDIO # Establecemos el objeto stream con nuestro archivo de audio
		
	random.randomize() # Establecemos la semilla para generar números aleatorios
	
	# Coje la pasada por parámetro y si no la voz1 como voz por defecto
	var tipo_voz : Dictionary = TIPOS_VOZ.get(voz, TIPOS_VOZ["voz1"]) 
	
	var min: float = tipo_voz["tono_base"] - tipo_voz["variacion"]
	var max: float = tipo_voz["tono_base"] + tipo_voz["variacion"]
	
	pitch_scale = random.randf_range(min,max) # Devuelve un float aleatorio entre el min y el max
	play()
