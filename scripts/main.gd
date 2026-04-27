# MAIN.gd
extends Node2D

var level: int = 1
var current_level_root: Node = null

# posição player
var saved_player_position: Vector2 = Vector2.ZERO
var has_saved_position: bool = false

# salva estado dos zumbis do level 1
var zombies_state: Dictionary = {}


func _ready() -> void:
	current_level_root = get_node("level_1")
	setup_level(current_level_root)


# ------------------------
# LEVELS
# ------------------------

func load_level(level_number: int) -> void:
	if current_level_root:
		current_level_root.queue_free()
		await get_tree().process_frame

	var level_path: String = "res://scenes/levels/level_%s.tscn" % level_number
	var scene: PackedScene = load(level_path)

	if scene == null:
		push_error("Level não encontrado")
		return

	current_level_root = scene.instantiate()
	current_level_root.name = "level_1"
	add_child(current_level_root)

	setup_level(current_level_root)

	var player = current_level_root.get_node_or_null("player")
	var camera = current_level_root.get_node_or_null("player/Camera2D")

	# voltar level 1
	if level_number == 1:
		if player and has_saved_position:
			player.global_position = saved_player_position + Vector2(0, 20)

		restore_zombies()

	if camera:
		camera.make_current()


# ------------------------
# SETUP
# ------------------------

func setup_level(level_root: Node) -> void:
	connect_area(level_root, "casa1Area", casa1)
	connect_area(level_root, "casa2Area", casa2)
	connect_area(level_root, "casa3Area", casa3)
	connect_area(level_root, "exitLevel1Area", level1)


func connect_area(level_root: Node, area_name: String, callback: Callable) -> void:
	var area = level_root.get_node_or_null(area_name)

	if area:
		area.body_entered.connect(callback)


# ------------------------
# SAVE ZUMBIS
# ------------------------

func save_zombies() -> void:
	zombies_state.clear()

	var enemies = current_level_root.get_node_or_null("Enemies")

	if enemies == null:
		return

	for zombie in enemies.get_children():
		zombies_state[zombie.name] = {
			"position": zombie.global_position,
			"health": zombie.health,
			"isAlive": zombie.isAlive
		}

func restore_zombies() -> void:
	var enemies = current_level_root.get_node_or_null("Enemies")

	if enemies == null:
		return

	for zombie in enemies.get_children():
		if zombies_state.has(zombie.name):
			var data = zombies_state[zombie.name]

			zombie.global_position = data["position"]
			zombie.health = data["health"]
			zombie.healthBar.update_health(zombie.health)

			# morto
			if data["isAlive"] == false:
				zombie.isAlive = false
				zombie.target = null
				zombie.targetInRange = false
				zombie.velocity = Vector2.ZERO

				if zombie.lastDirection.x >= 0:
					zombie.zombieAnimations.play("death_right")
				else:
					zombie.zombieAnimations.play("death_left")

				zombie.zombieAnimations.stop()
				zombie.zombieAnimations.frame = zombie.zombieAnimations.sprite_frames.get_frame_count(zombie.zombieAnimations.animation) - 1

				zombie.get_node("sigthArea/sigthHitbox").set_deferred("disabled", true)
				zombie.get_node("zombieHitbox").set_deferred("disabled", true)
				zombie.get_node("meleeArea/meleeHitbox").set_deferred("disabled", true)

			# vivo
			else:
				zombie.isAlive = true

				zombie.get_node("sigthArea/sigthHitbox").set_deferred("disabled", false)
				zombie.get_node("zombieHitbox").set_deferred("disabled", false)
				zombie.get_node("meleeArea/meleeHitbox").set_deferred("disabled", false)

# ------------------------
# TROCA LEVEL
# ------------------------

func change_level(new_level: int) -> void:
	if level == 1:
		save_zombies()

	level = new_level

	sceneTransition.get_node("AnimationPlayer").play("dissolve")
	await sceneTransition.get_node("AnimationPlayer").animation_finished

	await load_level(level)

	sceneTransition.get_node("AnimationPlayer").play_backwards("dissolve")


# ------------------------
# SIGNALS
# ------------------------

func casa1(body: Node2D) -> void:
	if body.name == "player":
		save_player_position(body)
		await change_level(2)


func casa2(body: Node2D) -> void:
	if body.name == "player":
		save_player_position(body)
		await change_level(3)


func casa3(body: Node2D) -> void:
	if body.name == "player":
		save_player_position(body)
		await change_level(4)


func level1(body: Node2D) -> void:
	if body.name == "player":
		await change_level(1)


func save_player_position(player: Node2D) -> void:
	saved_player_position = player.global_position
	has_saved_position = true
