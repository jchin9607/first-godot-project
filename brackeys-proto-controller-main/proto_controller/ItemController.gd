extends Node

@onready var projectile = get_tree().current_scene.get_node("Projectile")
@onready var ray : RayCast3D = get_parent().get_node("Head/Camera3D/aim")
@onready var cam : Camera3D = get_parent().get_node("Head/Camera3D")
@export var heldItem : Node3D

func _input(event: InputEvent) -> void:
	var new = null
	if event.is_action_pressed("click"):
		new = projectile.duplicate()
		
		
		var spawn_offset = 0.5
		var dir = -cam.global_transform.basis.z
		
		get_tree().current_scene.add_child(new)
	
		if ray.is_colliding():
			var target = ray.get_collision_point()
			var target_collider = ray.get_collider()
			if target_collider is RigidBody3D:
				target_collider.take_damage(10)
			new.started_shoot(heldItem.global_position + dir * spawn_offset, target)
			
			new.look_at(target)
			
		else:
			new.started_shoot(heldItem.global_position + dir * spawn_offset)
			new.global_rotation = cam.global_rotation
