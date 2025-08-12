extends Node

var default_port : int = 25565

func _ready() -> void:
	multiplayer.peer_connected.connect(lobby_join_event)

func start_lobby() -> void:
	var peer : MultiplayerPeer = ENetMultiplayerPeer.new()
	var err : Error = peer.create_server(default_port, NetworkManager.max_players)
	if err != OK:
		print("[ERROR] Cannot start server: ", err)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.emit(1) # Emit that the host joined...
	print("Finished creating server.")

func join_lobby(address : String = "localhost") -> bool:
	print("Attempting to join Enet Lobby... %s" % address)
	var peer : MultiplayerPeer = ENetMultiplayerPeer.new()
	var err : Error = peer.create_client(address, default_port)
	if err != OK:
		print("[ERROR] Cannot start client: ", err)
		return false
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	
	return true

@rpc("any_peer", "call_local")
func lobby_join_event(pid: int) -> void:
	print("Player Connected with PID: %d" % pid)
	if multiplayer.is_server(): NetworkManager.spawn_player(0, pid)
