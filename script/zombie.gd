extends CharacterBody3D
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var raycast: RayCast3D = $RayCast3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

const SPEED = 4.0
const DETECTION_RANGE = 15.0
const ATTACK_RANGE = 2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var dead = false
var is_attacking = false
var growl_sound = preload("res://sound/Zombie001_Attack_A_001.mp3")
var shot_sound = preload("res://sound/9mm Single.mp3")
var blood_sound = preload("res://sound/Blood_Splash_A_003.mp3")
var body_fall_sound = preload("res://sound/Foley_BodyFall_003.mp3")

func _ready():
	add_to_group("enemy")

func _physics_process(delta):
	if dead or is_attacking:
		return
	if player == null:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player <= DETECTION_RANGE:
		move_to_player()
		play_growl()
		if dist_to_player <= ATTACK_RANGE:
			attack()
	else:
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

func attack():
	is_attacking = true
	velocity.x = 0.0
	velocity.z = 0.0
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	rotation.y = atan2(dir.x, dir.z)
	$AnimatedSprite3D.play("shoot")
	play_sound(shot_sound)
	player.damage()
	print("damage dealt by ", name)
	await $AnimatedSprite3D.animation_finished
	is_attacking = false

func die():
	if dead:
		return
	dead = true
	Global.player_score += 100
	$CollisionShape3D.disabled = true
	velocity = Vector3.ZERO
	$AnimatedSprite3D.position.y -= 0.5
	$AnimatedSprite3D.play("die")
	play_sound(blood_sound)
	await get_tree().create_timer(0.15).timeout
	play_sound(body_fall_sound)

func play_growl():
	if dead:
		return
	if not audio.playing:
		audio.stream = growl_sound
		audio.play()

func play_sound(sound: AudioStream):
	audio.stream = sound
	audio.play()
