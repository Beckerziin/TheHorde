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

		if Input.is_action_just_pressed("attack") and not isAttacking:
			attack()

		if isAttacking:
			velocity = Vector2.ZERO
			return

		process_movement(delta)
		process_stamina(delta)
		process_health_regen(delta)
		process_animation()

		move_and_slide()

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

	print("Vida Atual:", health)
	print("Limite:", max_regen_health)

	if health >= max_regen_health:
		print("LIMITE ATINGIDO")
		return

	health += 1

	print("REGENEROU PARA:", health)

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
# ATAQUE
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
			playerFlashligth.position = Vector2(-xFlash, yFlash)
			playerFlashligth.rotation_degrees = 180

		Vector2.RIGHT:
			meleeHitbox.position = Vector2(xHitbox, yHitbox)
			meleeHitbox.rotation_degrees = 0
			playerFlashligth.position = Vector2(xFlash, yFlash)
			playerFlashligth.rotation_degrees = 0

		Vector2.UP:
			meleeHitbox.position = Vector2(yHitbox, -xHitbox)
			meleeHitbox.rotation_degrees = 270
			playerFlashligth.position = Vector2(yFlash, -xFlash)
			playerFlashligth.rotation_degrees = 270

		Vector2.DOWN:
			meleeHitbox.position = Vector2(yHitbox, xHitbox)
			meleeHitbox.rotation_degrees = 90
			playerFlashligth.position = Vector2(yFlash, xFlash)
			playerFlashligth.rotation_degrees = 90

#===========================
# DANO
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

	sceneTransition.changeScene(
		get_tree().current_scene.scene_file_path
	)

#===========================
# MELEE
#===========================

func _on_melee_area_body_entered(body: Node2D) -> void:

	if isAttacking and body.name.begins_with("zombie"):

		body.receiveDamage(strenght, position)

		if body.health <= 0:
			print("Zumbi morreu")
