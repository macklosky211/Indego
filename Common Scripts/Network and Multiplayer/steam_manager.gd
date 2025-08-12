extends Node
class_name Steam_Manager

### This object interacts directly with the locally running instance of steam.
### This is in charge of initializing and managing steam resources.
### Included in this object:
### steamID : int - the local players Steam ID
### username : String - the local players Steam User Name
### friends : Dictionary[SteamID, Friend] - A dictionary of steam users using the locally defined Friend class.

@export var should_steam_be_on : bool = true

var is_steam_running : bool = false

class Friend:
	var username : String
	var online_status : String
	
	func _to_string() -> String:
		return "{ Username: %s, Online_Status: %s }"  % [username, online_status]

var steamID : int
var username : String
var friends : Dictionary[int, Friend]

func _ready() -> void:
	if not should_steam_be_on: set_process(false); return
	
	var steam_initialized : bool = Steam.steamInit()
	if not steam_initialized or not Steam.isSteamRunning():
		push_error("Steam failed to initialize!")
		return
	else: is_steam_running = true
	
	steamID = Steam.getSteamID()
	username = Steam.getPersonaName()
	
	#if not Steam.isSubscribed(): get_tree().quit() # If the player does not own the game... quit?
	
	print("Steam is running: %s\nSteamID: %d\nSteam Name: %s" % [Steam.isSteamRunning(), steamID, username])
	_get_steam_friends()
	
	print("Steam Friends: ")
	print(friends)
	
	Steam.persona_state_change.connect(person_state_change)

func _process(_delta: float) -> void:
	Steam.run_callbacks() # This lets the signals work properlly... idk

func _get_steam_friends() -> void:
	var friend_count : int = Steam.getFriendCount(Steam.FRIEND_FLAG_IMMEDIATE)
	
	for i : int in range(friend_count):
		var friend_id : int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		if friend_id == 0: print("Steam_ID was 0, %d : %d" % [i, friend_id]); continue
		var friend_values : Friend = Friend.new()
		friend_values.username = Steam.getFriendPersonaName(friend_id)
		friend_values.online_status = get_friend_state(friend_id)
		
		friends.set(friend_id, friend_values)
	
func get_friend_state(id : int) -> String:
	var friend_state : int = Steam.getFriendPersonaState(id)
	return persona_state_to_string(friend_state)

func persona_state_to_string(state : int) -> String:
	match state:
		Steam.PERSONA_STATE_ONLINE: return "Online"
		Steam.PERSONA_STATE_OFFLINE: return "Offline"
		Steam.PERSONA_STATE_AWAY: return "Away"
		_: return "Unknown State: %d" % state

func person_state_change(id: int, flags: int) -> void:
	if id == steamID: return # This means it was our own state that changed.
	var new_state : String = ""
	if flags == Steam.PERSONA_CHANGE_GONE_OFFLINE: new_state = "Offline"
	elif flags == Steam.PERSONA_CHANGE_COME_ONLINE: new_state = "Online"
	if new_state == "": return
	var friend : Friend = friends.get(id)
	var old_status : String = friend.online_status
	friend.online_status = new_state
	print("Friend changed status (old: %s): %s" % [old_status, friend])
