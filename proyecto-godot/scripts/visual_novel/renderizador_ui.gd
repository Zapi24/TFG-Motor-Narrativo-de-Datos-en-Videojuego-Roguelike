# Este Script se encarga de rendereizar todos los elementos de la pantalla del Visual Novel en cada isnstante
extends Node

@export var fondo: TextureRect
@export var personaje: TextureRect
@export var personaje_antiguo: TextureRect
@export var nombre: Label
@export var texto: RichTextLabel
@export var imagen_siguiente: TextureRect
@export var fondo_antiguo: TextureRect
@export var director_animaciones: Node 

@onready var voz_personajes: AudioStreamPlayer = $VozPersonajes

# Variables para el texto progresivo
var escribiendo: bool = false
var cancelar_animacion: bool = false 
var id_escritura: int = 0 # Identificador único para evitar problemas de dos lineas de texto ejecutandose a la vez si se saltan muy rapido
var tipo_voz_actual: String = "voz1" # Almacena el tipo de voz actual
var ruta_fondo_anterior: String = "" # Para ir guardando la ruta de la iamgen de fondo y detectar cuando cambia
var ruta_personaje_anterior: String = "" # Para ir guardando la ruta del personaje y detectar cuando cambia
var nombre_anterior: String = "" # Para lo mismo q el resto de anteriores xd	

const VELOCIDAD_BASE: float = 0.03 #  Tiempo normal entre las letras
const PAUSA_CORTA: float = 0.15    # Pausa para comas
const PAUSA_LARGA: float = 0.35 # Pausa para puntos, interrogaciones etc

# Función que recibe la linea actual y actualiza todos los nodos dentro de la interfaz
func renderizar_pantalla(linea_actual: Dictionary) -> void:
	
	# Textos:
	nombre.text = linea_actual["nombre"]
	texto.text = linea_actual["texto"]
	
	# Voz:
	tipo_voz_actual = linea_actual.get("tipo_voz", "voz1")
	
	
	
	# Imagen de fondo: 
	var ruta_fondo_actual = linea_actual["ruta_fondo"]
	# Comprobamos que la ruta no está vacía y el archivo existe
	if not linea_actual["ruta_fondo"].is_empty() && ResourceLoader.exists(linea_actual["ruta_fondo"]):
		
		# Comprobamos si el fondo ha cambiado con respecto al ultimo estado
		if ruta_fondo_actual != ruta_fondo_anterior:
			
			# Caso A: Ejecutamos la transición con la animación
			if ruta_fondo_anterior != "":
				fondo_antiguo.texture = fondo.texture
				fondo_antiguo.show()
				fondo_antiguo.modulate.a = 1.0
				
				fondo.texture = load(ruta_fondo_actual)
				fondo.show()
				
				# Ejecutamos la animación
				await director_animaciones.crossfade_imagen_fondo(fondo)
				fondo_antiguo.hide()
			
			# Caso B: Lo mostramos de golpe (es la primera vez que se ejecuta)
			else:
				fondo.texture = load(ruta_fondo_actual)
				fondo.modulate.a = 1.0
				fondo.show()
			
			# Actualizamos el fondo actual
			ruta_fondo_anterior = ruta_fondo_actual
			
	# Si no hay ruta o el archivo no existe
	else: 
		fondo.texture = null
		fondo.hide()
		if not linea_actual["ruta_fondo"].is_empty():
			printerr("ERROR:  no se ha podido cargar la imagen del fondo para la ruta: ", linea_actual["ruta_fondo"]) 
		
	# Imagen del personaje:
	var ruta_personaje_actual: String = linea_actual["ruta_personaje"]
	var nombre_actual: String = linea_actual["nombre"]
	# Comprobamos que la ruta no está vacia y el archivo existe
	if not ruta_personaje_actual.is_empty() && ResourceLoader.exists(ruta_personaje_actual):
		#  COmprobamos que hubiese tambien una imagen anterior
		if not ruta_personaje_anterior.is_empty():
			# Si ambos tienen imagen, miramos el nombre para evaluar si iniciamos la animación de salto o de crossfade
			if ruta_personaje_actual != ruta_personaje_anterior:
				if nombre_actual != nombre_anterior:
					# CASO 1: Crossfade: hemos cambiado de imagen y de nombre
					personaje_antiguo.texture = personaje.texture
					personaje_antiguo.show()
					personaje_antiguo.modulate.a = 1.0	
					
					personaje.texture = load(ruta_personaje_actual)
					await director_animaciones.crossfade_personaje(personaje)
					
					personaje_antiguo.hide()
				else: 
					# CASO 2: Salto: Hemos cambiado de imagen pero el nombre se mantiene (se ha cambiado la pose)
					personaje.texture = load(ruta_personaje_actual)
					personaje.show()
					
					await director_animaciones.salto_personaje(personaje)
		else:
			# CASO 3: Animación de entrar: No teniamos ningun personaje y entra uno en escena
			personaje.texture = load(ruta_personaje_actual)
			await director_animaciones.deslizar_personaje(personaje, true)
		
		# Actualizamos la memoria el personaje
		ruta_personaje_anterior = ruta_personaje_actual
		nombre_anterior = nombre_actual
				
	else:
		if not ruta_personaje_anterior.is_empty():
			# CASO 2: Animación de salida: Teníamos un personaje y no sale ninguno
			await director_animaciones.deslizar_personaje(personaje,false)
			personaje.texture = null
		
		# Limpiamos 
		personaje.hide()
		personaje_antiguo.hide()
		ruta_personaje_anterior = ""
		nombre_anterior = nombre_actual
		
		if not ruta_personaje_actual.is_empty():
			printerr("ERROR: no se ha podido cargar la imagen del personaje para la ruta: ", ruta_personaje_actual)

	# Iniciamos la escritura
	iniciar_escritura()
	
func iniciar_escritura() -> void:
	# Cada vez que la ejecutamos creamos un nuevo id de escritura
	id_escritura += 1
	var id_actual: int = id_escritura
	
	_ocultar_indicador() # Ocultamos el indicador al empezar una nueva línea
	
	escribiendo = true
	cancelar_animacion = false
	texto.visible_characters = 0
	
	# Obtenemos la longitud total del texto que vamos a escribir
	# get_parsed_text() obtiene el texto limpio sin etiquetas BBCode internas
	var texto_limpio: String = texto.get_parsed_text()
	var long: int = texto_limpio.length()
	
	
	if long == 0: # Hemos introducido un texto vació, asi que no tenemos que poner nada
		texto.visible_characters = -1
		escribiendo = false
		_mostrar_indicador() # Lo mostramos si la línea está vacía
		return
	
	for i in range(long):
		# Hemos avanzado de linea, salimos del for
		if id_actual != id_escritura:
			return 
		# Si el usuario hace click o pulsa el espacio, paramos el bucle
		if cancelar_animacion:
			break
			
		# Revelamos las letras de uno en uno
		texto.visible_characters+=1
		
		# Vemos el caracter que acabamos de pasar para ver que tipo de pausa aplicamos
		var caracter: String = texto.get_parsed_text()[texto.visible_characters - 1]
		
		# Reproducimos el sonido (a no ser que sea un espacio)
		if caracter !=  " " and not voz_personajes.playing :
			voz_personajes.reproducir_voz(tipo_voz_actual)
		
		if not await _esperar_y_validar(VELOCIDAD_BASE, id_actual):
			return
		 
		# Vemos si necesitamos alguna pausa más
		if not cancelar_animacion:
			if caracter in [",", ";"]:
				if not await _esperar_y_validar(PAUSA_CORTA, id_actual):
					return
			elif caracter in [".", "?", "!", ":"]:
				if not await _esperar_y_validar(PAUSA_LARGA, id_actual):
					return
				
	# Al salir ya sea por que ha terminado la secuencia o por que lo hemos cancelado
	texto.visible_characters = -1 # Para que muestre todo
	escribiendo = false
	
	# Al terminar de escribir toda la frase, activamos la animación visual
	_mostrar_indicador()

func completar_texto_instantaneamente() -> void:
	cancelar_animacion = true
	# Cortamos el sonido de golpe si el usuario hace clic para autocompletar la frase
	if voz_personajes.playing:
		voz_personajes.stop()
	
# Función auxiliar que espera x y valida si el id actual sigue siendo valido
func _esperar_y_validar(tiempo: float, id_instancia: int) -> bool:
	await get_tree().create_timer(tiempo).timeout
	return id_instancia == id_escritura
	
# Funciones auxiliares 
func _mostrar_indicador() -> void:
	director_animaciones.animar_indicador_siguiente(imagen_siguiente)

func _ocultar_indicador() -> void:
	director_animaciones.detener_indicador_siguiente(imagen_siguiente)
	
	
