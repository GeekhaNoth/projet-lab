extends Node2D

func _ready() -> void:
	csv_to_json("res://data/csv_imported.csv", "res://data/imported.json")


func csv_to_json(csv_path: String, json_path: String):
	var file = FileAccess.open(csv_path, FileAccess.READ)

	var result = []

	while not file.eof_reached():
		var line = file.get_csv_line(";")

		# ignore lignes vides
		if line.size() == 0 or line[0] == "":
			continue

		result.append(line) # <-- IMPORTANT : on garde le format tableau

	file.close()

	var json_file = FileAccess.open(json_path, FileAccess.WRITE)
	json_file.store_string(JSON.stringify(result, "\t"))
	json_file.close()

	print("Conversion OK (format index identique CSV)")
