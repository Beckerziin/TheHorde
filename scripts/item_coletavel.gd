extends Area2D

@export var nome_do_item: String = "Porrete"
@export var imagem_do_item: Texture2D 

var player_perto: bool = false

@onready var texto_aviso: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if imagem_do_item != null:
		sprite.texture = imagem_do_item
	
	# Configura o texto inicial e esconde ele
	texto_aviso.text = "[E] Pegar " + nome_do_item
	texto_aviso.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_perto = true
		texto_aviso.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_perto = false
		texto_aviso.hide()

func _process(delta: float) -> void:
	if player_perto and Input.is_key_pressed(KEY_E):
		player_perto = false 
		InventoryManager.adicionar_item(nome_do_item, 1) 
		queue_free()
