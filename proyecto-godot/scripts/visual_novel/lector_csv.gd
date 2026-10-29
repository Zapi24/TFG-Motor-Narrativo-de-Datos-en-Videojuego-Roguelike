# Este Script se encarga de acceder a los distintos csv y meter su información en Json con la sigueinte forma:
# {
#     "nombre": "Punpun",
#     "texto": "Hola",
#     "ruta_fondo": "res://assets/fondo.png",
#     "ruta_personaje": "res://assets/personaje.png"
# }

extends Node

# Función que abre un archivo CSV y revuelve un Array de Diccionarios con su información en lineas
func procesar_csv(ruta_archivo: String) -> Array[Dictionary]:
	var datos_extraidos: Array[Dictionary] = []
	
	# Comprobamos si el archivo existe
	if not FileAccess.file_exists(ruta_archivo):
		printerr("ERROR: No se ha podido acceder al archivo CSV con ruta: ", ruta_archivo)
		return datos_extraidos # Se devuelven vacios
	
	var csv: FileAccess = FileAccess.open(ruta_archivo, FileAccess.READ)
	
	# Recorremos el archivo hasta su ultima linea con información
	while not csv.eof_reached(): # Devuelve true en cada iteracion hasta que lee cada linea del csv
	
		# OBtenemos las columnas para acceder a ellas de la siguiente manera
		# columnas[0] # "Punpun" (Nombre)
		# columnas[1] # "Hola" (Texto)
		# columnas[2] # "res://assets/fondo.png"
		# columnas[3] # "res://assets/personaje.png"	
		var columnas: PackedStringArray = csv.get_csv_line(",")
		
		# Metemos las columnas en cada fila del diccionario
		var fila: Dictionary = {
			"nombre": columnas[0].strip_edges(), # strip_edges elimina espacios en blanco o saltos de linea al principio o al final
			"texto": columnas[1].strip_edges(), 
			"ruta_fondo": columnas[2].strip_edges(),
			"ruta_personaje": columnas[3].strip_edges()
		}
		
		datos_extraidos.append(fila)
	
	return datos_extraidos
