class_name ObjectPool extends Node

# --- External Variables ---

@export var is_expandable : bool = true
@export var pool_size : int = 10

# --- Internal Variables ---

var index : int = 0
var pool : Pool = Pool.new()
var active_pool : Dictionary[Node, PoolObject]

# --- Functions ---

func fill_pool(scene : PackedScene, amount : int) -> void:
	assert(scene and scene.can_instantiate(), "Cant instantiate scene!!??!")
	assert(amount < 1000, "Amount is unreasonably high... what could you possibly be doing...")
	
	for i : int in range(amount):
		var new_node : Node3D = scene.instantiate()
		new_node.visible = false
		new_node.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(new_node, true)
		var new_obj : PoolObject = PoolObject.new(new_node)
		pool.push(new_obj)

## Assumes object is active. to return it to the pool make sure to call restore.
func get_next() -> Node:
	var obj : PoolObject = pool.get_next()
	if obj == null: return null
	active_pool.set(obj.node, obj)
	obj.is_active = true
	obj.node.visible = true
	obj.node.process_mode = Node.PROCESS_MODE_INHERIT
	return obj.node

func restore(node : Node3D) -> void:
	if active_pool.has(node):
		pool.push(active_pool[node])
		active_pool.erase(node)
		node.visible = false
		node.position = Vector3.ZERO
		node.process_mode = Node.PROCESS_MODE_DISABLED

func restore_all() -> void:
	for value : PoolObject in active_pool.values():
		pool.push(value)
	active_pool.clear()

# --- Classes ---

class Pool:
	var head : PoolObject = null
	var tail : PoolObject = null
	var size : int = 0
	
	func get_next() -> PoolObject:
		var temp : PoolObject = null
		if head != null:
			if head == tail:
				tail = null
			temp = head
			head = head.next
			size -= 1
		return temp
	
	func push(obj : PoolObject) -> void:
		if tail:
			tail.next = obj
			tail = obj
		else:
			head = obj
			tail = obj
		size += 1
	
	func _to_string() -> String:
		var string : String = "Elements: (%d)\n" % size
		var temp : PoolObject = head
		while(temp != null):
			string += "%s\n" % temp.to_string()
			temp = temp.next
		return string

class PoolObject:
	var node : Node3D = null
	var is_active : bool = false
	var next : PoolObject = null
	
	func has_next() -> bool:
		return next != null
	
	func _init(_node : Node, _is_active : bool = false) -> void:
		node = _node
		is_active = _is_active
	
	func _to_string() -> String:
		return "(%s : is_active: %s, has_next: %s)" % [node.name, is_active, has_next()]
