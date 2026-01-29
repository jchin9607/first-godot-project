extends RigidBody3D

var health = 100
@onready var healthbar = $SubViewport/healthbar

func _ready():
	healthbar.value = 100.0
	


func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()
	healthbar.value = health
	print(health)
	
	# health bar method to display might be taxing
	
