extends CharacterBody2D

signal died

var speed: int
var lastDirection: Vector2 = Vector2.RIGHT
var isAttacking: bool = false
var hitboxOffset: Vector2
var strenght: int
var maxHealth: int
var health: int
var alive: bool = true
@onready var playerAnimations: AnimatedSprite2D = $playerAnimations
@onready var punchSound: AudioStreamPlayer2D = $punchSound
@onready var meleeHitbox: Area2D = $meleeArea
@onready var hurtSound: AudioStreamPlayer2D = $hurtSound
@onready var damageCooldown: Timer = $damageCooldown
@onready var healthBar: CanvasLayer = $playerHealth



func _ready() -> void:
	#Carregar Stats das variaveis globais
	health = playerStats.health
	maxHealth = playerStats.maxHealth
	strenght = playerStats.strenght
	speed = playerStats.speed
	
	#Inicia o offset da hitbox
	hitboxOffset = meleeHitbox.position
	if healthBar:
		healthBar.update_health(health)
	

func _physics_process(delta: float) -> void:
	
	#Desativa a hitbox ate um ataque ser detectado
	meleeHitbox.monitoring = false
	
	if alive:
		if Input.is_action_just_pressed("attack") and not isAttacking:
			attack()
		
		if isAttacking:
			velocity = Vector2.ZERO
			return

		process_movement()
		process_animation()
		move_and_slide()

#SCRIPTS DE ATAQUE


#===========================
# SCRIPT PARA MOVIMENTAÇÃO 
#===========================

#1. PEGA OS INPUTS E DECIDE QUAL DIREÇÃO
func process_movement()-> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		velocity = direction * speed
		lastDirection = direction
		updateHitboxOffset()
	else:
		velocity = Vector2.ZERO

#2. DECIDE SE ESTA CORRENDO OU SE ESTÁ PARADO
func process_animation() -> void:
	if isAttacking == true:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", lastDirection)
	else:
		play_animation("idle", lastDirection)

#3. CONFIGURA QUAL A ANIMAÇÃO QUE O PERSONAGEM DEVE TER
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
# SCRIPT PARA ATAQUES 
#===========================

#1. ATAQUE CORPO-A-CORPO
func attack() -> void:
	if alive:
		isAttacking = true
		meleeHitbox.monitoring = true
		punchSound.play()
		play_animation("punch", lastDirection)
	

func detectFineshedAnimation() -> void:
	if isAttacking:
		isAttacking = false
		
#===========================
# SCRIPT PARA HITBOX 
#===========================

func updateHitboxOffset() -> void:
	var x := hitboxOffset.x
	var y := hitboxOffset.y
	
	
	match lastDirection:
		Vector2.LEFT:
			meleeHitbox.position = Vector2(-x, y)
			meleeHitbox.rotation_degrees = 180
		Vector2.RIGHT:
			meleeHitbox.position = Vector2(x, y)
			meleeHitbox.rotation_degrees = 0
		Vector2.UP:
			meleeHitbox.position = Vector2(y, -x)
			meleeHitbox.rotation_degrees = 270
		Vector2.DOWN:
			meleeHitbox.position = Vector2(y, x)
			meleeHitbox.rotation_degrees = 90

func receiveDamage(damageReceived: int) -> void:
	if alive:
		if damageCooldown.time_left > 0:
			return	
		health -= damageReceived
		healthBar.update_health(health)
		playerStats.health = health
		print('Player: '+ str(damageReceived) + ' foi recebido, vida atual do player ' + str(health))
		if health <= 0:
			die()
			return
		
		#Deixar player invecivel dps do dano por um tempinho
		damageCooldown.start()
		
		if !hurtSound.playing:
			hurtSound.play()

func die() -> void:
	alive = false
	play_animation("death_normal", lastDirection)
	
	## Desabilitar colisão
	$meleeArea/meleeHitbox.set_deferred("disabled", true)
	$playerHitbox.set_deferred("disabled", true)

	await playerAnimations.animation_finished
	
	sceneTransition.changeScene(get_tree().current_scene.scene_file_path)



func _on_melee_area_body_entered(body: Node2D) -> void:
	if isAttacking && body.name.begins_with('zombie'):
		body.receiveDamage(strenght, position)
		print('Player: ' + str(strenght) + ' de dano dado a ' + str(body.get_instance_id()) + ', vida atual do alvo ' + str(body.health))
		if body.health <= 0:
			print('Zumbi(' + str(body.get_instance_id()) + ') morreu')
