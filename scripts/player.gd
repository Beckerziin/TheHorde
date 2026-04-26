extends CharacterBody2D


const SPEED = 200.0

var lastDirection: Vector2 = Vector2.RIGHT
var isAttacking: bool = false
var hitboxOffset: Vector2
var strenght: int=20

@onready var player_animation: AnimatedSprite2D = $playerAnimation
@onready var punch_sound: AudioStreamPlayer2D = $punchSound
@onready var melee_hitbox: Area2D = $meleeHitbox


func _ready() -> void:
	
	#Inicia o offset da hitbox
	hitboxOffset = melee_hitbox.position
	

func _physics_process(delta: float) -> void:

	#Desativa a hitbox ate um ataque ser detectado
	melee_hitbox.monitoring = false

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
		velocity = direction * SPEED
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
		player_animation.play(prefix + "_right")
	elif dir.x < 0:
		player_animation.play(prefix + "_left")
	elif dir.y < 0:
		player_animation.play(prefix + "_up")
	elif dir.y > 0:
		player_animation.play(prefix + "_down")
		
#===========================
# SCRIPT PARA ATAQUES 
#===========================

#1. ATAQUE CORPO-A-CORPO
func attack() -> void:
	isAttacking = true
	melee_hitbox.monitoring = true
	punch_sound.play()
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
			melee_hitbox.position = Vector2(-x, y)
			melee_hitbox.rotation_degrees = 180
		Vector2.RIGHT:
			melee_hitbox.position = Vector2(x, y)
			melee_hitbox.rotation_degrees = 0
		Vector2.UP:
			melee_hitbox.position = Vector2(y, -x)
			melee_hitbox.rotation_degrees = 270
		Vector2.DOWN:
			melee_hitbox.position = Vector2(y, x)
			melee_hitbox.rotation_degrees = 90
		


func _on_melee_hitbox_body_entered(body: Node2D) -> void:
	if isAttacking && body.name.begins_with('zombie'):
		print(body.name)
		body.receiveDamage(strenght, position)
		print(body.health)
