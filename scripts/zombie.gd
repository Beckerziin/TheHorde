extends CharacterBody2D

const SPEED: int = 40
const knockbackForce: int = 10

var is_alive: bool = true
var target = null
var isAttacking = false
var lastDirection: Vector2 = Vector2.DOWN
var health: int=100

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $takeDamage
@onready var death_sound: AudioStreamPlayer2D = $deathSound
@onready var health_bar: Node2D = $HealthBar
@onready var zombieViewRadius: CollisionShape2D = $zombieSigth/CollisionShape2D


func _physics_process(delta: float) -> void:
	if is_alive and target:
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
	health_bar.update_health(health)
	if health <=0:
		_die()
	else:
		take_damage_sound.play()
		
		#knockback
		var knockbackDirection = (position - attackerPosition).normalized()
		var targetPosition = position + knockbackDirection * knockbackForce
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", targetPosition, 0.5)
	
	
func _die() -> void:
	if is_alive:
		play_animation("death", lastDirection)
		death_sound.play()
	is_alive = false
	
	## Desaibilitar colisão
	$zombieSigth/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	
func process_animation() -> void:
	if is_alive:
		if isAttacking == true:
			return
		if target != null:
			play_animation("walk", lastDirection)
		else:
			play_animation("idle", lastDirection)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x > 0:
		animated_sprite_2d.play(prefix + "_right")
	elif dir.x < 0:
		animated_sprite_2d.play(prefix + "_left")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")

func _on_zombie_sigth_body_entered(body: Node2D) -> void:
	if body.name == 'player':
		target = body
		zombieViewRadius.shape.set("radius", 144)


func _on_zombie_sigth_body_exited(body: Node2D) -> void:
	if body.name == 'player':
		target = null
