extends Area3D

var speed = 400

var go_to = null

var direction = null

var cooldown = 15
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	monitoring = false
	set_physics_process(false)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if go_to == null:
		position += -global_transform.basis.z * speed * delta
		cooldown -= delta
		print(cooldown)
		if cooldown <= 0:
			queue_free()
	else:
		position = position.move_toward(go_to, speed * delta )
		if position == go_to:
			
			queue_free()
	

	
	
func started_shoot(pos, end_pos = null):
	show()
	monitoring = true
	position = pos
	go_to = end_pos
	
		
		
	set_physics_process(true)
	
