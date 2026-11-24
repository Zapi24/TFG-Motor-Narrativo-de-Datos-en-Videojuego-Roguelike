# Se encarga exclusivamente de administrar la música de fondo y los efectos de sonido
extends Node

@onready var musica_fondo1: AudioStreamPlayer = $MusicaFondo1
@onready var musica_fondo2: AudioStreamPlayer = $MusicaFondo2
@onready var efectos_sonido: AudioStreamPlayer = $EfectosSonido

var cancion_activa: AudioStreamPlayer = null
var ruta_cancion_actual: String = ""
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
	# Si la celda del excel (ruta) está vacía, no cambiamos nada continua la reproducción de la canción actual
	if nueva_ruta.is_empty() or nueva_ruta == "":
		return
	
	if not ResourceLoader.exists(nueva_ruta):
		printerr("ERROR: No se ha podido acceder al archivo de audio con ruta: ", nueva_ruta)
		return
		
	# Hacemos el cambio para musica_fondo1 y 2
	var reproductor_nuevo: AudioStreamPlayer
	var reproductor_actual: AudioStreamPlayer = cancion_activa
	
	if cancion_activa == musica_fondo1:
		reproductor_nuevo = musica_fondo2
	else:
		reproductor_nuevo = musica_fondo1
			
	# Realizamos el crossfade: 
	# 1º Bajamos el volumen de la cancion actual si hubiese alguna sonando (lo bajamos a -80 decibelios)
	if reproductor_actual and reproductor_actual.playing:
		var tween_salida = create_tween()
		tween_salida.tween_property(reproductor_actual, "volume_db", -80.0, TIEMPO_CROSSFADE_AUDIO).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween_salida.finished
		reproductor_actual.stop() # Paramos la cancion cuando haya terminado
		
	# 2º Ponemos la segunda cancion:
	reproductor_nuevo.stream = load(nueva_ruta)
	reproductor_nuevo.volume_db = -80.0 # Empezamos en silencio
	reproductor_nuevo.play()
	
	var tween_entrada = create_tween()
	tween_entrada.tween_property(reproductor_nuevo, "volume_db", 0.0, TIEMPO_CROSSFADE_AUDIO).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween_entrada.finished
	
	# Actualizamos la memoria del gestor
	cancion_activa = reproductor_nuevo
	ruta_cancion_actual = nueva_ruta
	
# Para el botón de la interfaz para silenciar el canal MusicaFondo
func alternar_mute_musica() -> bool:
	var bus_id = AudioServer.get_bus_index("MusicaFondo")
	if bus_id != -1:
		var esta_muteado = AudioServer.is_bus_mute(bus_id)
		AudioServer.set_bus_mute(bus_id, not esta_muteado) # Si era true (estaba muteado) pasa a false y viceversa
		return not esta_muteado
	return false

	
