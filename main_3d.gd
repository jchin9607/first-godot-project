extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player : PackedScene = preload("res://brackeys-proto-controller-main/proto_controller/proto_controller.tscn")



func _on_singleplayer_pressed() -> void:
	add_player()
	
func add_player(id = 1):
	var p = player.instantiate()
	p.name = str(id)
	
	call_deferred("add_child", p)
	$hostjoin.hide()

func _on_host_pressed() -> void:
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$hostjoin.hide()
	
	$PillarSpawner.queue_free()
	$Skeleton.queue_free()
	

func _on_join_pressed() -> void:
	peer.create_client("127.0.0.1", 1027)
	multiplayer.multiplayer_peer = peer
	$hostjoin.hide()
	
	$PillarSpawner.queue_free()
	$Skeleton.queue_free()
	
func exit_game(id):
	multiplayer.peer_connected.connect(del_player)
	del_player(id)
	
func del_player(id):
	rpc("_del_player", id)
	
@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
	
