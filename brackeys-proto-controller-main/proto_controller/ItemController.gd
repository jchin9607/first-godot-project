extends Node

@onready var projectile = get_tree().current_scene.get_node("Projectile")
@onready var ray : RayCast3D = get_parent().get_node("Head/Camera3D/aim")
@onready var cam : Camera3D = get_parent().get_node("Head/Camera3D")
@export var heldItem : Node3D
@export var gun : MeshInstance3D
@export var sword : MeshInstance3D
@onready var hurtbox = get_parent().get_node("Head/Camera3D/hurtbox")
@onready var weoponlabel = get_tree().current_scene.get_node("CanvasLayer2/WeoponLabel")

signal swing()


var current_item = State.GUN 

enum State {
	GUN,
	SWORD
}

func _ready():
	weoponlabel.text = "Gun"
	gun.visible = true
	sword.visible = false

func _input(event: InputEvent) -> void:
	if !get_parent().is_multiplayer_authority():
		return
	var new = null
	if event.is_action_pressed("click"):
		if current_item == State.GUN:
			new = projectile.duplicate()
			
			
			var spawn_offset = 0.5
			var dir = -cam.global_transform.basis.z
			
			get_tree().current_scene.add_child(new)
		
			if ray.is_colliding():
				var target = ray.get_collision_point()
				var target_collider = ray.get_collider()
				if target_collider is RigidBody3D:
					target_collider.take_damage(10)
				if target_collider is CharacterBody3D:
					target_collider.take_damage.rpc_id(target_collider.name.to_int(), 10)
					
					
				new.started_shoot(heldItem.global_position + dir * spawn_offset, target)
				
				new.look_at(target)
				
			else:
				new.started_shoot(heldItem.global_position + dir * spawn_offset)
				new.global_rotation = cam.global_rotation
				
		if current_item == State.SWORD:
			var bodies = hurtbox.get_overlapping_bodies()
			for body in bodies:
				if body != get_parent() and body is RigidBody3D:
					body.take_damage(15)
				if body != get_parent() and body is CharacterBody3D:
					body.take_damage.rpc_id(body.name.to_int(), 15)
					
			swing.emit()
			
			
			
	if event.is_action_pressed("gun"):
		current_item = State.GUN
		weoponlabel.text = "Gun"
		gun.visible = true
		sword.visible = false
		
	if event.is_action_pressed("sword"):
		current_item = State.SWORD
		weoponlabel.text = "Sword"
		gun.visible = false
		sword.visible = true
