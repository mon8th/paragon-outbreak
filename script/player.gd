extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 0.05
@onready var ui_script = $ui
@onready var ray = $Camera3D/RayCast3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	add_to_group("player")

func _physics_process(delta):
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
		self.rotate_y(TURN_SPEED)
	if Input.is_action_pressed("ui_right"):
		self.rotate_y(-TURN_SPEED)	
		
	if Input.is_action_pressed("ui_accept"):
		if ui_script.can_shoot:
			shoot()
	
	move_and_slide()

func shoot():
	var sound_player = $AudioStreamPlayer

	match Global.current_weapon:
		"gun":
			sound_player.stream = preload("res://sound/gun.ogg")
		"machine":
			sound_player.stream = preload("res://sound/machine.ogg")
		"mini":
			sound_player.stream = preload("res://sound/mini.ogg")

	sound_player.play()
	
	if ray.is_colliding() and ray.get_collider().has_method("die"):
		ray.get_collider().die()
		
func damage():
	Global.player_health -= 10
	print(Global.player_health)
	if Global.player_health <= 0:
		if Global.lives <= 1:
			queue_free()
		else:
			Global.lives -= 1
			get_tree().change_scene_to_file("res://world.tscn")
