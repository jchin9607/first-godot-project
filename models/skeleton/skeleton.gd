extends RigidBody3D

var health = 100


func _ready():
	var healthbar = $SubViewport/healthbar
	healthbar.value = 100.0
	


func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()
	var healthbar = $SubViewport/healthbar
	healthbar.value = health
	print(health)
	
	# health bar method to display might be taxing
	

	
	



		
