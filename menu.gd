extends Node2D

@onready var start_button = $VBoxContainer/Start

func _ready():
	start_button.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_button_down() -> void:
	get_tree().change_scene_to_file("res://main_3d.tscn")
