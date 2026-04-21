extends CharacterBody2D


const SPEED = 250.0
@onready var player_animation: AnimatedSprite2D = $playerAnimation
var lastDirection: Vector2 = Vector2.RIGHT
var isAttacking: bool = false


func _physics_process(delta: float) -> void:

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
	play_animation("punch", lastDirection)
	print("attack")


func detectFineshedAnimation() -> void:
	if isAttacking:
		isAttacking = false
