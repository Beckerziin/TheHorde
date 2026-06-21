extends CanvasLayer

@onready var stamina_bar: Sprite2D = $fullSprite

@onready var default_width = stamina_bar.region_rect.size.x
@onready var default_height = stamina_bar.region_rect.size.y

func update_stamina(new_stamina: int) -> void:
	#resize stamina_bar
	var new_width = (new_stamina / 100.0) * default_width	
	stamina_bar.region_rect = Rect2(0,0, new_width, default_height)
