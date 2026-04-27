extends Control

var bus_index: int

func _ready() -> void:
	# Prepara o barramento de áudio Master
	bus_index = AudioServer.get_bus_index("Master")
	
	# Deixa a bolinha do slider na posição certa baseada no volume atual
	# Atenção: Certifique-se de que o nome do nó na aba Cena é exatamente "HSlider"
	$HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))


func _process(delta: float) -> void:
	pass


func _on_sair_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu-inicial/main_menu.tscn")


# --- NOVA FUNÇÃO DO VOLUME ---
func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
