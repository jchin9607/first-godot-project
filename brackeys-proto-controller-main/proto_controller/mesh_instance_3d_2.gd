extends MeshInstance3D

@onready var base_rot = rotation
@onready var tween : Tween

@onready var base_pos = position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !is_multiplayer_authority():
		return
	$"../../../../ItemController".swing.connect(_on_swing)
	
	
func _on_swing():
	if tween:
		tween.kill()
	rotation = base_rot
	position = base_pos
	tween = create_tween()
	var target_rot = base_rot
	target_rot.y = deg_to_rad(-120)
	var target_pos = base_pos + Vector3(0.5, 0, -0.5)
	tween.tween_property(self, "rotation", target_rot, 0.14 )
	tween.tween_property(self, "position", target_pos, 0.14)
	
	tween.tween_property(self, "rotation", base_rot, 0.14 )
	tween.tween_property(self, "position", base_pos, 0.14)
	
	
	
	
	
	
