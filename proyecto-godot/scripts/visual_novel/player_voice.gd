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

func reproducir_voz(perfil: String) -> void:
