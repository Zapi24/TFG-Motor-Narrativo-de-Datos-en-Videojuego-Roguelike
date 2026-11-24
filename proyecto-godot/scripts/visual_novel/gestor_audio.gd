# Se encarga exclusivamente de administrar la música de fondo y los efectos de sonido
extends Node

@onready var musica_fondo1: AudioStreamPlayer = $MusicaFondo1
@onready var musica_fondo2: AudioStreamPlayer = $MusicaFondo2
@onready var efectos_sonido: AudioStreamPlayer = $EfectosSonido

var cancion_activa: AudioStreamPlayer = null
var ruta_cancion_atual: String = ""
var TIEMPO_CROSSFADE_AUDIO: float = 1.5

# Lo cargamos nada mas empezar
func _ready() -> void:
	# La función finised se encarga de que cuando el objeto AudioStream termine, se ejecute la función adyacente, es decir cuando termine se ejecuta de vuelta
	musica_fondo1.finished.connect(_crossface_cancion_finalizar.bind(musica_fondo1))
	musica_fondo2.finished.connect(_crossface_cancion_finalizar.bind(musica_fondo2))

# Hace que la misma canción se vuelva a ejecutar cuando se acabe
func _crossface_cancion_finalizar(reproductor: AudioStreamPlayer) -> void:
	# Comprobamos que la cancion que se acaba de acabar sea la activa, y que efectivamente ya no se encuentre sonando
	if reproductor == cancion_activa and not reproductor.playing:
		cancion_activa.play()

# Para los efectos de sonido (los ejecuta directamente)
func reproducir_efecto_sonido(ruta: String) -> void:
	if not ruta.is_empty() and ResourceLoader.exists(ruta):
		efectos_sonido.stream = load(ruta)
		efectos_sonido.play()

# Para las canciones de fondo
func cambiar_cancion(nueva_ruta: String) -> void:
	
	
	
func cambiar_cancion(nueva_ruta: String) -> void:
	# 1. Única restricción: si la celda del Excel está vacía, no se hace nada y la música sigue
	if nueva_ruta.is_empty():
		return
		
	# 2. Validación de seguridad en disco
	if not ResourceLoader.exists(nueva_ruta):
		printerr("ERROR: No se encuentra el archivo de audio para la ruta: ", nueva_ruta)
		return
		
	# 3. Determinamos reproductor entrante y saliente
	var reproductor_entrante: AudioStreamPlayer
	var reproductor_saliente: AudioStreamPlayer = cancion_activa
	
