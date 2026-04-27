extends Node

var strenght: int = 100
var maxHealth: int = 100
var health: int = 100
var speed = 600.0
var zombiesKilled = 0
var maxZombies: int = 24


func reset() ->void:
	health = maxHealth
