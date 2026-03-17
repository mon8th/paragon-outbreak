extends CharacterBody3D
const SPEED = 20.0
const TURN_SPEED = 0.10
const KNIFE_RANGE = 2.0
@onready var ui_script = $ui
@onready var ray = $Camera3D/RayCast3D
@onready var sound_player = $AudioStreamPlayer
@onready var restart_screen = $Restart
@onready var ending_video = $"../CanvasLayer/EndingVideo"
@onready var black_overlay = $"../CanvasLayer/ColorRect"
@onready var dialog_label = $"../CanvasLayer/Label"
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_dead = false
var end_position = Vector3(250.69, 0.22, -29.25)
var ending_triggered = false

func _ready():
	add_to_group("player")
	restart_screen.visible = false
	black_overlay.hide()
	dialog_label.hide()
	ending_video.hide()

func _physics_process(delta):
	if is_dead:
		return
	if not ending_triggered and global_position.distance_to(end_position) < 3.0:
		ending_triggered = true
		trigger_ending()
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

func trigger_ending():
	get_tree().paused = true
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	black_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_label.process_mode = Node.PROCESS_MODE_ALWAYS
	ending_video.process_mode = Node.PROCESS_MODE_ALWAYS

	# show black screen with text
	black_overlay.modulate.a = 1.0
	black_overlay.show()
	dialog_label.modulate.a = 0.0
	dialog_label.show()

	# fade in text
	var tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_property(dialog_label, "modulate:a", 1.0, 1.5)
	await tween.finished

	# hold text
	await get_tree().create_timer(3.0, true).timeout

	# fade out text
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_property(dialog_label, "modulate:a", 0.0, 1.0)
	await tween.finished
	dialog_label.hide()

	# start video BEFORE fading black so world never shows
	ending_video.show()
	ending_video.play()

	# fade black away to reveal video underneath
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_property(black_overlay, "modulate:a", 0.0, 2.0)
	await tween.finished
	black_overlay.hide()

	ending_video.finished.connect(func(): get_tree().quit())

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
	sound_player.stop()
	sound_player.stream = preload("res://sound/01. Death Groan (Male).wav")
	sound_player.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	restart_screen.show_game_over()
	await get_tree().create_timer(2.0).timeout
	Global.player_health = 100
	Global.player_score = 0
	get_tree().reload_current_scene()
