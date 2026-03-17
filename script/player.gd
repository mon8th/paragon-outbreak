extends CharacterBody3D

const SPEED = 5.0
const TURN_SPEED = 0.05
const KNIFE_RANGE = 2.0

@onready var ui_script = $ui
@onready var ray = $Camera3D/RayCast3D
@onready var sound_player = $AudioStreamPlayer
@onready var restart_screen = $Restart

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_dead = false

func _ready():
	add_to_group("player")
	restart_screen.visible = false

func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if Input.is_action_pressed("ui_left"):
		rotate_y(TURN_SPEED)
	if Input.is_action_pressed("ui_right"):
		rotate_y(-TURN_SPEED)

	if Input.is_action_pressed("ui_accept") and ui_script.can_shoot:
		shoot()

	move_and_slide()

func shoot():
	var target = null

	if ray.is_colliding():
		target = ray.get_collider()

	match Global.current_weapon:
		"gun":
			sound_player.stream = preload("res://sound/gun.ogg")
		"machine":
			sound_player.stream = preload("res://sound/machine.ogg")
		"mini":
			sound_player.stream = preload("res://sound/mini.ogg")
		"knife":
			sound_player.stream = preload("res://sound/Knife.wav")

	sound_player.play()

	if target == null:
		return

	if Global.current_weapon == "knife":
		var dist = global_position.distance_to(target.global_position)
		if dist <= KNIFE_RANGE and target.has_method("die"):
			target.die()
	else:
		if target.has_method("die"):
			target.die()

func damage():
	if is_dead:
		return

	Global.player_health -= 5
	print("health = ", Global.player_health)

	if Global.player_health <= 0:
		die()

func die():
	if is_dead:
		return

	is_dead = true
	Global.player_health = 0

	print("GAME OVER TRIGGERED")

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	restart_screen.show_game_over()

	await get_tree().create_timer(2.0).timeout

	Global.player_health = 100
	Global.player_score = 0

	get_tree().reload_current_scene()
