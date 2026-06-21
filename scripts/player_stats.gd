extends Node

var strenght: int = 100
var maxHealth: int = 100
var health: int = 100
var speed = 180.0
var zombiesKilled = 0
var maxZombies: int = 24
var stamina: int = 100
var maxStamina: int = 100


func reset() ->void:
	health = maxHealth
	stamina = maxStamina
	
