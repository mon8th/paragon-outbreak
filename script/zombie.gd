extends CharacterBody3D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var raycast: RayCast3D = $RayCast3D

const SPEED = 5.0
const DETECTION_RANGE = 15.0
const ATTACK_RANGE = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var dead = false
var is_attacking = false
var can_see_player = false

func _ready():
	add_to_group("enemy")

func _physics_process(delta):
	if dead or is_attacking:
		return

	if player == null:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	can_see_player = check_can_see_player()

	if can_see_player:
		move_to_player()
		attack()
	else:
		# Stop moving when player is not visible
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

func move_to_player():
	var dir = player.global_position - global_position
	dir.y = 0.0
	
	if dir.length() > 0:
		dir = dir.normalized()
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		rotation.y = atan2(dir.x, dir.z)

func check_can_see_player() -> bool:
	var dist_to_player = global_position.distance_to(player.global_position)

	# Too far = cannot see
	if dist_to_player > DETECTION_RANGE:
		return false

	# Aim raycast toward player
	var target_pos = player.global_position
	var local_target = to_local(target_pos)
	raycast.target_position = local_target
	raycast.force_raycast_update()

	# Check if raycast hits player
	if raycast.is_colliding():
		return raycast.get_collider() == player

	return false

func attack():
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > ATTACK_RANGE:
		return

	is_attacking = true

	# Stop while attacking
	velocity.x = 0.0
	velocity.z = 0.0

	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	rotation.y = atan2(dir.x, dir.z)

	$AnimatedSprite3D.play("shoot")

	if raycast.is_colliding() and raycast.get_collider().has_method("damage"):
		raycast.get_collider().damage()

	await $AnimatedSprite3D.animation_finished
	is_attacking = false

func die():
	dead = true
	Global.player_score += 100
	$CollisionShape3D.disabled = true
	
	$AnimatedSprite3D.position.y -= 0.5
	$AnimatedSprite3D.play("die")
