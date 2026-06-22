extends Area2D

@onready var interface_mapa: CanvasLayer = $"../InterfaceMapa"
var player_no_alcance: bool = false

func _ready() -> void:
	if interface_mapa:
		interface_mapa.visible = false
	else:
		# Se este aviso aparecer no teu terminal, significa que o caminho do nó está errado!
		print("⚠️ ERRO: O nó 'InterfaceMapa' não foi encontrado! Verifica o nome ou a posição dele.")

func _input(event: InputEvent) -> void:
	# Deteta o clique único da tecla E (evita que o mapa abra e feche sem parar)
	if player_no_alcance and event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_E:
			if interface_mapa:
				interface_mapa.visible = !interface_mapa.visible
				print("🗺️ Estado do Mapa Grande alterado! Visível: ", interface_mapa.visible)

func _on_body_entered(body: Node2D) -> void:
	if body.name.begins_with("player") or body.name == "player":
		player_no_alcance = true
		print("🚶‍♂️ Player encostou na mesa!")

func _on_body_exited(body: Node2D) -> void:
	if body.name.begins_with("player") or body.name == "player":
		player_no_alcance = false
		print("🏃‍♂️ Player saiu de perto da mesa!")
		if interface_mapa:
			interface_mapa.visible = false
