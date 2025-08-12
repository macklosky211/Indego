extends Node
class_name Steam_Peer_Manager

enum BROADCAST_FLAG {CONNECTING, DISCONNECTING}

var signals_setup : bool = false
var lobby_id : int

func setup_signals() -> void:
	Steam.lobby_created.connect(lobby_created_event)
	Steam.lobby_joined.connect(lobby_joined_event)
	Steam.join_requested.connect(lobby_join_requested_event)
	signals_setup = true

func start_lobby() -> void:
	if not signals_setup: setup_signals()
	print("Attempting to start steam lobby...")
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, NetworkManager.max_players) # Lobby_Joined_Even, Lobby_Created_Event, and Lobby_Data_Event will all trigger from this call.

func join_lobby(target_lobby_id : String) -> bool:
	if not signals_setup: setup_signals()
	print("Attempting to join steam lobby... %s" % target_lobby_id)
	
	Steam.joinLobby(target_lobby_id.strip_edges().to_int()) # Lobby_Joined_Event will be triggered by this.
	return true

func lobby_created_event(creation_status: int, created_lobby_id: int) -> void:
	if creation_status != Steam.RESULT_OK: push_error("Failed to create lobby"); return
	
	lobby_id = created_lobby_id
	print("Created lobby with ID: %d" % created_lobby_id)

	Steam.setLobbyJoinable(lobby_id, true)
	var set_relay: bool = Steam.allowP2PPacketRelay(true)
	print("Allowing Steam to be relay backup: %s" % set_relay)
	
	
func lobby_joined_event(joined_lobby_id : int, permissions : int, locked : bool, response : int) -> void:
	print("Lobby Joined Event: %d %d %s %d" % [joined_lobby_id, permissions, locked, response])
	print("According to steam, you have connected to lobby: ", joined_lobby_id)
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS: 
		var FAIL_REASON: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: FAIL_REASON = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: FAIL_REASON = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: FAIL_REASON = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: FAIL_REASON = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: FAIL_REASON = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: FAIL_REASON = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: FAIL_REASON = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: FAIL_REASON = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: FAIL_REASON = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: FAIL_REASON = "A user you have blocked is in the lobby."
		print("Failed to join steam lobby: ", FAIL_REASON)
		return

	var lobby_owner : int = Steam.getLobbyOwner(joined_lobby_id)
	
	print("Creating multiplayer peer...")
	var peer : MultiplayerPeer = SteamMultiplayerPeer.new()
	var result : Error
	
	if SteamManager.steamID == lobby_owner: result = peer.create_host(0); print("Lobby has no host... so its you now :)") # 0 == default virtual port
	else: result = peer.create_client(lobby_owner, 0); print("Joining lobby as a client.")

	if result != OK:
		push_error("Failed to create SteamMultiplayerPeer: ", result)
		return
	
	multiplayer.multiplayer_peer = peer

	print("[%d] Finished Connecting to Lobby " % multiplayer.get_unique_id(), joined_lobby_id)
	
	# If my understanding is correct, this signal will only be emitted when the local steam user joins a lobby.
	# SOO we just need to broadcast who this person is to the rest of the lobby.
	broadcast_lobby_event.rpc(multiplayer.get_unique_id(), SteamManager.steamID, BROADCAST_FLAG.CONNECTING)

func lobby_join_requested_event(joined_lobby_id : int, friend_id : int) -> void:
	var friend_name : String = Steam.getFriendPersonaName(friend_id)
	print("[STEAM] Attempting to join %s's lobby" % friend_name)
	join_lobby(str(joined_lobby_id))


## This function is called across all clients (Including self)
## it reports when players join the game or disconnect from the game.
@rpc("any_peer", "call_local")
func broadcast_lobby_event(pid : int, steamID: int, flag : BROADCAST_FLAG) -> void:
	print("Broadcast_Lobby_event was triggered by: %d %d, they are %s" % [pid, steamID, flag])
	match flag:
		BROADCAST_FLAG.CONNECTING: NetworkManager.spawn_player(steamID, pid)
		BROADCAST_FLAG.DISCONNECTING: print("[%d, %d] Disconnected from the server." % steamID, pid)
		_: print("Unknown broadcast flag %s" % flag)
