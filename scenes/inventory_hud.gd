extends CanvasLayer

@export var textura_normal: Texture2D       # Imagem "Inventory-Cell.png"
@export var textura_selecionada: Texture2D  # Imagem "Inventory-Chosen.png"

@onready var slot1: TextureRect = $HBoxContainer/Slot1
@onready var slot2: TextureRect = $HBoxContainer/Slot2
@onready var slot3: TextureRect = $HBoxContainer/Slot3

@onready var slots_visuais = [slot1, slot2, slot3]
var slot_selecionado: int = 0

func _ready() -> void:
	if InventoryManager:
		InventoryManager.inventario_atualizado.connect(atualizar_textos)
	destacar_slot_ativo()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_1:
			mudar_slot(0)
		elif event.keycode == KEY_2:
			mudar_slot(1)
		elif event.keycode == KEY_3:
			mudar_slot(2)

func mudar_slot(novo_index: int) -> void:
	if slot_selecionado != novo_index:
		slot_selecionado = novo_index
		InventoryManager.slot_ativo = novo_index
		destacar_slot_ativo()

func destacar_slot_ativo() -> void:
	# Coloca o fundo normal em todos
	for slot in slots_visuais:
		slot.texture = textura_normal
	
	# Coloca o fundo de borda iluminada no selecionado
	slots_visuais[slot_selecionado].texture = textura_selecionada

func atualizar_textos() -> void:
	# 1. Limpa as imagens antigas de todos os slots primeiro
	for slot in slots_visuais:
		if slot.has_node("ItemTexture"):
			slot.get_node("ItemTexture").texture = null
		
	var index = 0
	# 2. Passa pelos itens guardados e coloca a imagem deles na tela
	for nome_item in InventoryManager.itens.keys():
		if index < 3: 
			var dados_do_item = InventoryManager.itens[nome_item]
			var slot_atual = slots_visuais[index]
			
			# Procura o nó da imagem e coloca o desenho da arma/item
			if slot_atual.has_node("ItemTexture"):
				slot_atual.get_node("ItemTexture").texture = dados_do_item["textura"]
				
			index += 1
