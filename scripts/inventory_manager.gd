extends Node

signal inventario_atualizado

var itens: Dictionary = {}
var slot_ativo: int = 0

var dano_das_armas: Dictionary = {
	"Porrete": 10,
	"Faca": 15,
	"Shotgun": 30
}

func adicionar_item(nome_do_item: String, quantidade: int, textura: Texture2D) -> void:
	if itens.has(nome_do_item):
		itens[nome_do_item]["quantidade"] += quantidade
	else:
		# Guarda o pacotinho com a quantidade e a textura
		itens[nome_do_item] = {
			"quantidade": quantidade,
			"textura": textura
		}
		
	inventario_atualizado.emit()

func obter_dano_extra() -> int:
	var chaves_dos_itens = itens.keys()
	if slot_ativo < chaves_dos_itens.size():
		var nome_do_item_na_mao = chaves_dos_itens[slot_ativo]
		if dano_das_armas.has(nome_do_item_na_mao):
			return dano_das_armas[nome_do_item_na_mao]
			
	return 0

# =================================================================
# FUNÇÕES NOVAS PARA CONSUMÍVEIS (BANDAGEM)
# =================================================================

# Retorna o nome do item que está selecionado na hotbar agora
func obter_nome_item_ativo() -> String:
	var chaves_dos_itens = itens.keys()
	if slot_ativo < chaves_dos_itens.size():
		return chaves_dos_itens[slot_ativo]
	return ""

# Reduz a quantidade do item ativo. Se zerar, remove do inventário
func consumir_item_ativo() -> void:
	var nome_item = obter_nome_item_ativo()
	
	if nome_item != "":
		itens[nome_item]["quantidade"] -= 1
		
		# Se acabou o estoque do item, deleta ele do dicionário
		if itens[nome_item]["quantidade"] <= 0:
			itens.erase(nome_item)
			
		# Emite o sinal para a HUD atualizar e sumir com a imagem na hora
		inventario_atualizado.emit()
