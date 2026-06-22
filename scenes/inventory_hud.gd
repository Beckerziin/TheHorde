extends CanvasLayer

@onready var slot1: ColorRect = $HBoxContainer/Slot1
@onready var slot2: ColorRect = $HBoxContainer/Slot2
@onready var slot3: ColorRect = $HBoxContainer/Slot3

@onready var slots_visuais = [slot1, slot2, slot3]
var slot_selecionado: int = 0 

func _ready() -> void:
	InventoryManager.inventario_atualizado.connect(atualizar_textos)
	destacar_slot_ativo()

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_1):
		mudar_slot(0)
	elif Input.is_key_pressed(KEY_2):
		mudar_slot(1)
	elif Input.is_key_pressed(KEY_3):
		mudar_slot(2)

func mudar_slot(novo_index: int) -> void:
	if slot_selecionado != novo_index:
		slot_selecionado = novo_index
		destacar_slot_ativo()

func destacar_slot_ativo() -> void:
	# Apaga todos com cinza escuro
	for slot in slots_visuais:
		slot.color = Color(0.15, 0.15, 0.15)
	
	# Acende o selecionado com cinza claro
	slots_visuais[slot_selecionado].color = Color(0.6, 0.6, 0.6)

func atualizar_textos() -> void:
	# Reseta todos os textos para Vazio antes de escrever os novos
	for slot in slots_visuais:
		slot.get_child(0).text = "Vazio"
		
	var index = 0
	for nome_item in InventoryManager.itens.keys():
		if index < 3: 
			var quantidade = InventoryManager.itens[nome_item]
			
			# Pega o Label (primeiro filho) do slot e atualiza o texto
			var label_do_slot = slots_visuais[index].get_child(0)
			label_do_slot.text = nome_item + "\nx" + str(quantidade)
			index += 1
