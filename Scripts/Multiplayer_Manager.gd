extends Node
class_name Multiplayer_Manager

signal Connected
signal Disconnected
signal Connection_Failed(error: String)

var is_client_connected : bool = false

@onready var player_spawner: MultiplayerSpawner = $"../Players/PlayerSpawner"

@export var address : String = "localhost" # "72.196.212.7"
@export var port : int = 25565
@export var max_players : int = 4

func _ready() -> void:
	Connected.connect(func(): is_client_connected = true)
	Disconnected.connect(func(): is_client_connected = false)
	Disconnected.connect(Disconnect_All)
	Connection_Failed.connect(connection_failure)

## Spawn a new player in. Hook the player up to their multipalyer auth
func peer_connected(id: int) -> void:
	print("Peer Connected: ", id)
	
	if multiplayer.is_server():
		player_spawner.spawn([id])

func connection_failure() -> void:
	print("Connection failed.")
	Connection_Failed.emit("Failed to connect to the server.")
	Disconnected.emit()

func peer_disconnected(id: int) -> void:
	print("Peer Disconnected: ", id)


func server_connection_failure() -> void:
	print("Server Connection Failed?")
	Connection_Failed.emit("Server Connection Failed.")
	Disconnected.emit()


func connected_to_server() -> void:
	print("Connected to the server")
	Connected.emit()
	$"../MainMenu".visible = false

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_players)
	if err != OK:
		print("[ERROR] Cannot start server: ", err)
		Disconnected.emit()
		return
	is_client_connected = true
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	print("Server Started")
	Connected.emit()
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	# Call "peer_connected" to add the host to the game.
	multiplayer.peer_connected.emit(1)
	$"../MainMenu".visible = false

func start_client() -> void:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(address, port)
	if err != OK:
		print("[ERROR] Cannot start client: ", err)
		Connection_Failed.emit("Failed to create client: %s" % err)
		Disconnected.emit()
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	print("Connecting to server...")
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(server_connection_failure)
	multiplayer.connection_failed.connect(connection_failure)
	$"../MainMenu".visible = false

## This function makes me sad, but is nessisairy.
func Disconnect_All() -> void:
	if multiplayer.peer_connected.is_connected(peer_connected):
		multiplayer.peer_connected.disconnect(peer_connected)
	if multiplayer.peer_disconnected.is_connected(peer_disconnected):
		multiplayer.peer_disconnected.disconnect(peer_disconnected)
	if multiplayer.connected_to_server.is_connected(connected_to_server):
		multiplayer.connected_to_server.disconnect(connected_to_server)
	if multiplayer.server_disconnected.is_connected(server_connection_failure):
		multiplayer.server_disconnected.disconnect(server_connection_failure)
	if multiplayer.connection_failed.is_connected(connection_failure):
		multiplayer.connection_failed.disconnect(connection_failure)
	is_client_connected = false
	print("Disconnected.")
