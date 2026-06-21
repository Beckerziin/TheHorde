extends Node

signal inventario_atualizado

# Guarda apenas o nome e a quantidade. Ex: {"Pistola": 1, "Faca": 2}
var itens: Dictionary = {}

func adicionar_item(nome_do_item: String, quantidade: int = 1) -> void:
	if itens.has(nome_do_item):
		itens[nome_do_item] += quantidade
	else:
		itens[nome_do_item] = quantidade
		
	inventario_atualizado.emit()
