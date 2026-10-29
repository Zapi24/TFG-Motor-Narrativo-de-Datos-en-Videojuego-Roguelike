# Este Script se encarga de rendereizar todos los elementos de la pantalla del Visual Novel en cada isnstante
extends Node

@export var fondo: TextureRect
@export var personaje: TextureRect
@export var nombre: Label
@export var texto: RichTextLabel

# Función que recibe la linea actual y actualiza todos los nodos dentro de la interfaz

func renderizar_pantalla(linea_actual: Dictionary) -> void:
	
	# Textos:
	nombre.text = linea_actual["nombre"]
	texto.text = linea_actual["texto"]
	
	# Imagen del fondo (siempre habrá una, no puede ser vacio)
	if not linea_actual["ruta_fondo"].is_empty() && ResourceLoader.exists(linea_actual["ruta_fondo"]):
		fondo.texture = load(linea_actual["ruta_fondo"])
		fondo.show()
	else: 
		fondo.texture = null
		fondo.hide()
		if not linea_actual["ruta_fondo"].is_empty():
			printerr("ERROR:  no se ha podido cargar la imagen del fondo para la ruta: ", linea_actual["ruta_fondo"]) 
		
	# Imagen del personaje
	if not linea_actual["ruta_personaje"].is_empty() && ResourceLoader.exists(linea_actual["ruta_personaje"]):
		fondo.texture = load(linea_actual["ruta_personaje"])
		fondo.show()
	else:
		personaje.texture = null
		personaje.hide()
		# El personaje puede ser vacio por si no queremos mostrar en alguna iteración este	
	
