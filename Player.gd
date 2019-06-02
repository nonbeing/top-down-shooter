extends KinematicBody2D

const MOVE_SPEED = 300
onready var raycast = $RayCast2D
onready var sprite = get_node("AnimatedSprite")

var anim = "idle"
var trail = null

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
	

	if Input.is_action_just_pressed("shoot"):
		anim = "shoot"
		
		
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("kill_zombie"):
			trail = draw_bullet_trail(to_local(coll.position))
			coll.kill_zombie()
		else:
			trail = draw_bullet_trail(get_local_mouse_position())
			
	if Input.is_action_just_released("shoot"):
		if trail != null:
			trail.queue_free()
		
	sprite.play(anim)
 
func kill_player():
	# player is dead; restart the game
	get_tree().reload_current_scene()
	
	
func draw_bullet_trail(target):
	var trail = Line2D.new()
#	trail.set_name("bullet_trail")
	var line_endpoint_vectors = [Vector2(), Vector2(target.x, target.y)]
	
	var trail_points = PoolVector2Array(line_endpoint_vectors)
	trail.set_points(trail_points)
	trail.set_width(2)
	trail.set_default_color(Color(0.7, 0.7, 0))
	add_child(trail)
	return trail

#func _draw():
#	draw_line(Vector2(), Vector2(190,20), Color(0, 0, 1), 10, true)
#	if SHOOTING:
#		print("drawing bullet trail")
#		draw_line(Vector2(), Vector2(190,20), Color(0, 0, 1), 10, true)
##		draw_line(Vector2(), get_local_mouse_position(), Color(0, 0, 1), 10, true)
##	SHOOTING = false