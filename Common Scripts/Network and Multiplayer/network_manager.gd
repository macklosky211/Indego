extends Node
class_name Network_Manager

### This class will decide which multiplayer system the player is trying to use...
### IFF the player specifies an IP address we will start the ENet Services, otherwise we will default to steam.

## Represents the type of network the player is attempting to join.
enum NETWORK_TYPE {STEAM, ENET}

var max_players : int = 4
static var selected_network_type : NETWORK_TYPE

## By increasing this number we can simulate lag.
var simulated_latency_target : float = 0.0

var simulated_latency : float = 0.0

func _ready() -> void:
	get_tree().multiplayer_poll = false

func _process(delta : float) -> void:
	simulated_latency += delta
	if simulated_latency >= simulated_latency_target:
		simulated_latency = 0.0
		multiplayer.poll() # This calls all @rpc's and multiplayer sync's & spawners. AKA all mutliplayer functionality.


func join_lobby(lobby_id: String) -> bool:
	if lobby_id.is_valid_ip_address() or lobby_id == "localhost": selected_network_type = NETWORK_TYPE.ENET; return ENetPeerManager.join_lobby(lobby_id)
	else: selected_network_type = NETWORK_TYPE.STEAM; return SteamPeerManager.join_lobby(lobby_id)

func host_lobby(lobby_type : bool) -> void:
	if lobby_type: ENetPeerManager.start_lobby(); selected_network_type = NETWORK_TYPE.ENET
	else: SteamPeerManager.start_lobby(); selected_network_type = NETWORK_TYPE.STEAM

func spawn_player(steamID : int, playerID : int) -> void:
	var main_scene : Node = get_node_or_null("/root/Main")
	while main_scene == null:
		await get_tree().process_frame
		main_scene = get_node_or_null("/root/Main") # This is the best code i have ever written
	
	if not main_scene.is_main_scene_ready: await main_scene.main_scene_is_ready # Honestly dont need to do this... but it cant hurt.
	
	if multiplayer.is_server(): var _Player : Player_Controller = main_scene.get_node("Players/PlayerSpawner").spawn([steamID, playerID])
