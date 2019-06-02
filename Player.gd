extends KinematicBody2D

const MOVE_SPEED = 300
const BULLET_TRAIL_TIME = 0.08  # seconds
const BULLET_TRAIL_COLOR = "#e2b822"  # html color code

onready var raycast = $RayCast2D
onready var sprite = get_node("AnimatedSprite")
onready var bullet_spawn_point = $BulletSpawnPoint
onready var bullet_trail_timer = $BulletTrailTimer

# default player animation is "idle"
var anim = "idle"
var trail = null


func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)
	bullet_trail_timer.set_wait_time(BULLET_TRAIL_TIME)
	bullet_trail_timer.set_one_shot(true)
	
	
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
	
	var trail_weakref = null
	
	if Input.is_action_just_pressed("shoot"):
		anim = "shoot"
		bullet_trail_timer.start()
		
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("kill_zombie"):
			trail = draw_bullet_trail(to_local(coll.position))
			coll.kill_zombie()
		else:
			# Note that y is always 0 in the following Vector2:
			# The origin is always the center of the player (in the local co-ord system)
			# so we effectively always want a bullet trail along the positive x-axis where y is 0
			trail = draw_bullet_trail(50 * Vector2(bullet_spawn_point.position.x, 0))
		
		trail_weakref = weakref(trail);

	# In case the player is pressing LMB too rapidly,
	# there can be duplicate bullet trails, so to err on the side of caution, delete the last known trail
	# on LMB-release
	if Input.is_action_just_released("shoot"):
		# weakref source: https://godotengine.org/qa/2773/detect-if-an-object-reference-is-freed?show=2773#q2773
		if trail_weakref && trail_weakref.get_ref():  # reference still exists, delete trail
			trail.queue_free()
		
	sprite.play(anim)
 
func kill_player():
	# player is dead; restart the game
	get_tree().reload_current_scene()
	
	
func draw_bullet_trail(target):
	var trail = Line2D.new()
	var trail_start = Vector2(bullet_spawn_point.position.x, bullet_spawn_point.position.y)
	var trail_end = Vector2(target.x, target.y)
	var trail_points = PoolVector2Array([trail_start, trail_end])
	trail.set_points(trail_points)
	trail.set_width(2)
	trail.set_default_color(Color(BULLET_TRAIL_COLOR))
	add_child(trail)
	return trail

func _on_BulletTrailTimer_timeout():
	bullet_trail_timer.stop()
	if trail != null:
		trail.queue_free()
