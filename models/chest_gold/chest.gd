extends StaticBody3D

var player_nearby = false
@onready var lid = $chest_gold2/chest_gold/chest_gold_lid

var closed_rotation = 0.0
var open_rotation = deg_to_rad(-100)




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		player_nearby = true
		


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and player_nearby == true:
		player_nearby = false
	
		
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace") and player_nearby:
		toggle_lid()
		

func toggle_lid():
	var tween = create_tween()
	
	var target_rot : int
	
	if lid.rotation.x == 0:
		target_rot = open_rotation
	else:
		target_rot = closed_rotation
		
	tween.tween_property(lid, "rotation:x", target_rot, 0.5)
	
