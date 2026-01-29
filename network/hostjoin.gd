extends CanvasLayer


func _on_join_button() -> void:
	NetworkHandler.start_client()


func _on_host_button() -> void:
	NetworkHandler.start_server()
