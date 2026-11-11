extends Control

# Rutas que vamos a usar (ajústalas si tus carpetas se llaman distinto)
const CARPETA_DIALOGOS = "res://data/dialogues/"
const RUTA_NOVELA_VISUAL = "res://scenes/visual_novel/visual_novel_main.tscn"

@onready var contenedor_botones = $ScrollContainer/VBoxContainer

func _ready() -> void:
	_escanear_carpeta()

func _escanear_carpeta() -> void:
	var directorio = DirAccess.open(CARPETA_DIALOGOS)
	
	if directorio:
		directorio.list_dir_begin()
		var archivo = directorio.get_next()
		
		# Recorremos todo lo que hay en la carpeta
		while archivo != "":
			if not directorio.current_is_dir():
				# Filtramos para que solo coja .csv o .txt y ignore los archivos .import de Godot
				if archivo.ends_with(".csv") or archivo.ends_with(".txt"):
					_crear_boton_para_archivo(archivo)
			archivo = directorio.get_next()
	else:
		printerr("CRÍTICO: No se pudo abrir la ruta de diálogos: ", CARPETA_DIALOGOS)

func _crear_boton_para_archivo(nombre_archivo: String) -> void:
	var boton = Button.new()
	boton.text = " Cargar: " + nombre_archivo
	boton.custom_minimum_size = Vector2(300, 60) # Botones grandes y cómodos
	
	var ruta_completa = CARPETA_DIALOGOS + nombre_archivo
	
	# Conectamos el clic del botón a nuestra función, pasándole la ruta del archivo
	boton.pressed.connect(_al_pulsar_boton.bind(ruta_completa))
	
	contenedor_botones.add_child(boton)

func _al_pulsar_boton(ruta_seleccionada: String) -> void:
	# 1. Guardamos la ruta en nuestro puente invisible
	DebugData.ruta_csv_seleccionada = ruta_seleccionada
	# 2. Cargamos tu juego principal
	get_tree().change_scene_to_file(RUTA_NOVELA_VISUAL)
