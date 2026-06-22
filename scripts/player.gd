extends CharacterBody2D

signal died

var speed: int
var lastDirection: Vector2 = Vector2.RIGHT
var isAttacking: bool = false
var hitboxOffset: Vector2
var playerFlashligthOffset: Vector2
var strenght: int
var maxHealth: int
var health: int
var alive: bool = true
var isAiming: bool = false
var shotgunRangeArea: Area2D = null

#===========================
# STAMINA
#===========================
var stamina: float = 100.0
var maxStamina: float = 100.0

const SPRINT_MULTIPLIER := 1.4
const STAMINA_COST_RUN := 15.0
const STAMINA_COST_MELEE := 10.0
const STAMINA_REGEN := 15.0

#===========================
# REGENERAÇÃO DE VIDA
#===========================
const HEALTH_REGEN_RATE := 0.1
const HEALTH_REGEN_LIMIT := 0.4 # 40%

var can_regen_health := false

var flashlight_on: bool = false 

@onready var playerAnimations: AnimatedSprite2D = $playerAnimations
@onready var punchSound: AudioStreamPlayer2D = $punchSound
@onready var meleeHitbox: Area2D = $meleeArea
@onready var hurtSound: AudioStreamPlayer2D = $hurtSound
@onready var damageCooldown: Timer = $damageCooldown
@onready var healthBar: CanvasLayer = $playerHealth
@onready var staminaBar: CanvasLayer = $playerStamina
@onready var healthRegenDelay: Timer = $healthRegenDelay
@onready var playerFlashligth: PointLight2D = $playerFlashligth

func _ready() -> void:
	health = playerStats.health
	maxHealth = playerStats.maxHealth
	strenght = playerStats.strenght
	speed = playerStats.speed

	stamina = maxStamina

	hitboxOffset = meleeHitbox.position
	playerFlashligthOffset = playerFlashligth.position

	if healthBar:
		healthBar.update_health(health)

	update_stamina_ui()

func _physics_process(delta: float) -> void:
	meleeHitbox.monitoring = false

	if alive:
		# Checa se está com a Shotgun na mão para permitir mirar
		var item_atual = InventoryManager.obter_nome_item_ativo()
		
		if item_atual == "Shotgun":
			# Segurar botão direito do mouse ativa a mira
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				if not isAiming:
					isAiming = true
					print("Mirando com a Shotgun...")
			else:
				if isAiming:
					isAiming = false
					print("Soltou a mira.")
		else:
			isAiming = false # Se trocar de arma, cancela a mira automática

		# Se estiver atacando ou mirando, o boneco fica parado para atirar/bater
		if isAttacking or isAiming:
			velocity = Vector2.ZERO
			# Se o jogador clicar com o botão esquerdo enquanto mira, ele atira!
			if Input.is_action_just_pressed("attack") and item_atual == "Shotgun":
				shoot_shotgun()
			elif isAiming:
				# Mantém a animação de idle virada para a última direção enquanto mira
				play_animation("idle", lastDirection)
				move_and_slide()
				return
			else:
				return

		# Ataque normal de perto para outras armas ou soco
		if Input.is_action_just_pressed("attack") and not isAttacking:
			attack()

		process_movement(delta)
		process_stamina(delta)
		process_health_regen(delta)
		process_animation()

		move_and_slide()

#===========================
# ATAQUE DE LONGE (SHOTGUN)
#===========================

func shoot_shotgun() -> void:
	if not alive:
		return
		
	if stamina < STAMINA_COST_MELEE:
		return
		
	stamina -= STAMINA_COST_MELEE
	update_stamina_ui()
	
	isAttacking = true
	meleeHitbox.monitoring = true 
	
	# Aqui você pode dar play em um som específico de tiro depois!
	punchSound.play() 
	
	play_animation("punch", lastDirection) 
	print("🔥 BUM! Tiro de Shotgun desferido!")

#===========================
# ENTRADA DE INPUT (USAR ITEM)
#===========================

func _input(event: InputEvent) -> void:
	if alive:
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.keycode == KEY_Q: 
				tentar_usar_item()

func tentar_usar_item() -> void:
	var item_na_mao = InventoryManager.obter_nome_item_ativo()
	
	if item_na_mao == "Bandagem":
		if health < maxHealth:
			curar(30) 
			InventoryManager.consumir_item_ativo()
		else:
			print("Vida já está cheia, bandagem guardada.")

func curar(quantidade_cura: int) -> void:
	health += quantidade_cura
	if health > maxHealth:
		health = maxHealth
		
	playerStats.health = health
	
	if healthBar:
		healthBar.update_health(health)
	print("Curou! Vida atual: ", health)

#===========================
# STAMINA
#===========================

func update_stamina_ui() -> void:
	if staminaBar:
		staminaBar.update_stamina(stamina)

func process_stamina(delta: float) -> void:
	var is_running := Input.is_action_pressed("run")
	var is_moving := velocity != Vector2.ZERO

	if not (is_running and is_moving):
		var old_stamina = stamina

		stamina += STAMINA_REGEN * delta
		stamina = clamp(stamina, 0.0, maxStamina)

		if old_stamina != stamina:
			update_stamina_ui()

#===========================
# REGENERAÇÃO DE VIDA
#===========================

func process_health_regen(delta: float) -> void:
	if not can_regen_health:
		return

	var max_regen_health = int(maxHealth * HEALTH_REGEN_LIMIT)

	if health >= max_regen_health:
		return

	health += 1
	playerStats.health = int(health)

	if healthBar:
		healthBar.update_health(int(health))
		
func _on_health_regen_delay_timeout() -> void:
	print("REGEN LIBERADA")
	can_regen_health = true

#===========================
# MOVIMENTO
#===========================

func process_movement(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	var current_speed = speed

	if Input.is_action_pressed("run") and stamina > 0:
		current_speed = int(speed * SPRINT_MULTIPLIER)

		if direction != Vector2.ZERO:
			stamina -= STAMINA_COST_RUN * delta
			stamina = max(stamina, 0.0)
			update_stamina_ui()

	if direction != Vector2.ZERO:
		velocity = direction * current_speed
		lastDirection = direction
		updateHitboxOffset()
	else:
		velocity = Vector2.ZERO

#===========================
# ANIMAÇÕES
#===========================

func process_animation() -> void:
	if isAttacking:
		return

	if velocity != Vector2.ZERO:
		play_animation("run", lastDirection)
	else:
		play_animation("idle", lastDirection)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x > 0:
		playerAnimations.play(prefix + "_right")
	elif dir.x < 0:
		playerAnimations.play(prefix + "_left")
	elif dir.y < 0:
		playerAnimations.play(prefix + "_up")
	elif dir.y > 0:
		playerAnimations.play(prefix + "_down")

#===========================
# ATAQUE CORPO A CORPO
#===========================

func attack() -> void:
	if not alive:
		return

	if stamina < STAMINA_COST_MELEE:
		return

	stamina -= STAMINA_COST_MELEE
	update_stamina_ui()

	isAttacking = true
	meleeHitbox.monitoring = true

	punchSound.play()
	play_animation("punch", lastDirection)

func detectFineshedAnimation() -> void:
	if isAttacking:
		isAttacking = false

#===========================
# HITBOX/LANTERNA
#===========================

func _input(event: InputEvent) -> void:

	if Input.is_action_just_pressed("flashligth"):

		flashlight_on = !flashlight_on

		if flashlight_on:
			playerFlashligth.energy = 0.59
		else:
			playerFlashligth.energy = 0.0

func updateHitboxOffset() -> void:
	var xHitbox := hitboxOffset.x
	var yHitbox := hitboxOffset.y
	var xFlash := playerFlashligthOffset.x
	var yFlash := playerFlashligthOffset.y

	match lastDirection:
		Vector2.LEFT:
			meleeHitbox.position = Vector2(-xHitbox, yHitbox)
			meleeHitbox.rotation_degrees = 180
<<<<<<< Updated upstream
			playerFlashligth.position = Vector2(-xFlash, yFlash)
			playerFlashligth.rotation_degrees = 180

=======
>>>>>>> Stashed changes
		Vector2.RIGHT:
			meleeHitbox.position = Vector2(xHitbox, yHitbox)
			meleeHitbox.rotation_degrees = 0
<<<<<<< Updated upstream
			playerFlashligth.position = Vector2(xFlash, yFlash)
			playerFlashligth.rotation_degrees = 0

=======
>>>>>>> Stashed changes
		Vector2.UP:
			meleeHitbox.position = Vector2(yHitbox, -xHitbox)
			meleeHitbox.rotation_degrees = 270
<<<<<<< Updated upstream
			playerFlashligth.position = Vector2(yFlash, -xFlash)
			playerFlashligth.rotation_degrees = 270

=======
>>>>>>> Stashed changes
		Vector2.DOWN:
			meleeHitbox.position = Vector2(yHitbox, xHitbox)
			meleeHitbox.rotation_degrees = 90
			playerFlashligth.position = Vector2(yFlash, xFlash)
			playerFlashligth.rotation_degrees = 90

#===========================
# DANO RECEBIDO
#===========================

func receiveDamage(damageReceived: int) -> void:
	if alive:
		if damageCooldown.time_left > 0:
			return

		can_regen_health = false
		healthRegenDelay.start()

		health -= damageReceived

		if healthBar:
			healthBar.update_health(health)

		playerStats.health = health
		print("Player recebeu ", damageReceived, " de dano")

		if health <= 0:
			die()
			return

		damageCooldown.start()

		if !hurtSound.playing:
			hurtSound.play()

func die() -> void:
	alive = false
	play_animation("death_normal", lastDirection)

	$meleeArea/meleeHitbox.set_deferred("disabled", true)
	$playerHitbox.set_deferred("disabled", true)

	await playerAnimations.animation_finished
	sceneTransition.changeScene(get_tree().current_scene.scene_file_path)

#===========================
# MELEE / TIRO AREA (IDENTIFICAÇÃO DE ARMA)
#===========================

func _on_melee_area_body_entered(body: Node2D) -> void:
	if isAttacking and body.name.begins_with("zombie"):
		var item_na_mao = InventoryManager.obter_nome_item_ativo()
		var dano_total = strenght + InventoryManager.obter_dano_extra()

		body.receiveDamage(dano_total, position)
		
		# Feedback e mensagens customizadas de acordo com o item equipado
		if item_na_mao == "Shotgun":
			print("Tiro de Shotgun atingiu o zumbi! Dano: ", dano_total)
		elif item_na_mao == "Porrete":
			print("Porrete esmagou o zumbi! Dano: ", dano_total)
		else:
			print("Soco causou: ", dano_total, " de dano!")

		if body.health <= 0:
			print("Zumbi morreu")
