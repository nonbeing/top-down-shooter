extends KinematicBody2D

const MOVE_SPEED = 300
onready var raycast = $RayCast2D
onready var sprite = get_node("AnimatedSprite")

var anim = "idle"

func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)
	
func _physics_process(delta):
	var move_vec = Vector2()
	
	if Input.is_action_pressed("move_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("move_down"):
		move_vec.y += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1

	
	move_vec = move_vec.normalized()
#	print("DEBUG x:{x}, y:{y}".format({"x":move_vec.x, "y":move_vec.y}))
	
	if move_vec == Vector2.ZERO:
		anim = "idle"
	else:
		anim = "move"
	
	move_and_collide(move_vec * MOVE_SPEED * delta)
	
	# turn towards the mouse pointer
	look_at(get_global_mouse_position())
	
# another way to turn towards the mouse pointer: using vector math
#	var look_vec = get_global_mouse_position() - global_position
#	global_rotation = atan2(look_vec.y, look_vec.x)
   
	if Input.is_action_just_pressed("shoot"):
		anim = "shoot"
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("kill_zombie"):
			coll.kill_zombie()
			
	sprite.play(anim)
 
func kill_player():
	# player is dead; restart the game
	get_tree().reload_current_scene()