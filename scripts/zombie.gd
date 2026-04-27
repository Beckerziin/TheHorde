extends CharacterBody2D

const SPEED: int = 40
const knockbackForce: int = 10

var isAlive: bool = true
var target = null
var targetTemp = null
var targetInRange = false
var lastDirection: Vector2 = Vector2.DOWN
var health: int=100
var strength: int=10

@onready var zombieAnimations: AnimatedSprite2D = $zombieAnimations
@onready var takeDamageSound: AudioStreamPlayer2D = $takeDamage
@onready var deathSound: AudioStreamPlayer2D = $deathSound
@onready var healthBar: Node2D = $healthBar
@onready var zombieViewRadius: CollisionShape2D = $sigthArea/sigthHitbox
@onready var attackTimer: Timer = $attackTimer


func _physics_process(delta: float) -> void:
	if isAlive and target:
		playerTracking(delta)
		process_animation()
	
func playerTracking(delta: float) -> void:
	
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		lastDirection = direction
	else:
		velocity = Vector2.ZERO

func receiveDamage(damageReceived: int, attackerPosition: Vector2) -> void:
	health -= damageReceived
	healthBar.update_health(health)
	if health <=0:
		_die()
	else:
		if !takeDamageSound.playing:
			takeDamageSound.play()
		
		#knockback
		var knockbackDirection = (position - attackerPosition).normalized()
		var targetPosition = position + knockbackDirection * knockbackForce
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", targetPosition, 0.5)
	
	
func _die() -> void:
	if !isAlive:
		return

	isAlive = false
	playerStats.zombiesKilled += 1
	print('zumbis Mortos'+ str(playerStats.zombiesKilled))
	if lastDirection.x >= 0:
		zombieAnimations.play("death_right")
	else:
		zombieAnimations.play("death_left")

	$sigthArea/sigthHitbox.set_deferred("disabled", true)
	$zombieHitbox.set_deferred("disabled", true)
	$meleeArea/meleeHitbox.set_deferred("disabled", true)

	await zombieAnimations.animation_finished

	zombieAnimations.stop()
	zombieAnimations.frame = zombieAnimations.sprite_frames.get_frame_count(zombieAnimations.animation) - 1
	
func process_animation() -> void:
	if !isAlive:
		return

	if targetInRange:
		return

	if target != null:
		play_animation("walk", lastDirection)
	else:
		play_animation("idle", lastDirection)

func play_animation(prefix: String, dir: Vector2) -> void:
	if prefix == "death":
		if dir.x >= 0:
			zombieAnimations.play("death_right")
		else:
			zombieAnimations.play("death_left")

		zombieAnimations.stop()
		zombieAnimations.frame = zombieAnimations.sprite_frames.get_frame_count(zombieAnimations.animation) - 1
		return
	
	if isAlive:
		if dir.x > 0:
			zombieAnimations.play(prefix + "_right")
		elif dir.x < 0:
			zombieAnimations.play(prefix + "_left")
		elif dir.y < 0:
			zombieAnimations.play(prefix + "_up")
		elif dir.y > 0:
			zombieAnimations.play(prefix + "_down")
		
	if prefix == "death":
		if dir.x >= 0:
			zombieAnimations.play("death_right")
		else:
			zombieAnimations.play("death_left")
		return
	
	if isAlive:
		if dir.x > 0:
			zombieAnimations.play(prefix + "_right")
		elif dir.x < 0:
			zombieAnimations.play(prefix + "_left")
		elif dir.y < 0:
			zombieAnimations.play(prefix + "_up")
		elif dir.y > 0:
			zombieAnimations.play(prefix + "_down")

func _on_zombie_sigth_body_entered(body: Node2D) -> void:
	if body.name == 'player' and isAlive:
		target = body
			


func _on_zombie_sigth_body_exited(body: Node2D) -> void:
	if body.name == 'player' and isAlive: 
		target = null


func _on_melee_area_body_entered(body: Node2D) -> void:
	if body.name == 'player' and isAlive:
		targetInRange = true
		play_animation("attack",lastDirection)
		body.receiveDamage(strength)
		targetTemp = target
		target = null
		attackTimer.start()
		await zombieAnimations.animation_finished
		play_animation("idle",lastDirection)
		
		
		
		
		
func _on_melee_area_body_exited(body: Node2D) -> void:
	if body.name == 'player' and isAlive:
		await zombieAnimations.animation_finished
		target = body
		targetInRange = false
		attackTimer.stop()


func _on_attack_timer_timeout() -> void:
	if targetTemp and targetInRange and isAlive:
		play_animation("attack",lastDirection)
		targetTemp.receiveDamage(strength)
		await zombieAnimations.animation_finished
		play_animation("idle",lastDirection)
