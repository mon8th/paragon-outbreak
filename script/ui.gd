extends CanvasLayer

var time_since_last_shot = 0.0
var fire_rate = 1.0
var can_shoot = true
var weapon_textures = {
	"gun": preload("res://pictures/hudgun.png"),
	"machine": preload("res://pictures/hudmachinegun.png"),
	"mini": preload("res://pictures/hudmini.png"),
	"knife": preload("res://pictures/hudknife.png") 
}

func _ready():
	$AnimatedSprite2D.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
	$AnimatedSprite2D.play(Global.current_weapon + "_idle")
	$bj.play("100") 
	update_weapon_icon()

func _process(delta):
	time_since_last_shot += delta
	can_shoot = time_since_last_shot >= (1.0 / fire_rate)
	
	if Global.current_weapon != "knife" and Global.ammo <= 0:
		Global.current_weapon = "knife"
		$AnimatedSprite2D.play("knife_idle")
	
	if Input.is_action_pressed("ui_select") and can_shoot:
		
		if Global.current_weapon == "knife":
			$AnimatedSprite2D.play("stab")
		else:
			$AnimatedSprite2D.play(Global.current_weapon + "_shoot")
		
		time_since_last_shot = 0.0
		
		if Global.current_weapon != "knife":
			if Global.ammo > 0:
				Global.ammo -= 1
	
	match Global.current_weapon:
		"gun":
			fire_rate = 3.0
		"machine":
			fire_rate = 6.0
		"mini":
			fire_rate = 10.0
		"knife":
			fire_rate = 2.0
		_:
			fire_rate = 1.0
			
	update_weapon_icon()
	update_health_label()
	update_ammo_label()
	update_lives_label()
	update_score_label()
	update_level_label()
	update_face_animation(Global.player_health)
	
func update_weapon_icon():
	if $WEAPON.texture != weapon_textures[Global.current_weapon]:
		$WEAPON.texture = weapon_textures[Global.current_weapon]

func _on_AnimatedSprite2D_animation_finished():
	$AnimatedSprite2D.play(Global.current_weapon + "_idle")

func update_health_label():
	$HEALTH.text = str(Global.player_health)

func update_lives_label():
	$LIVES.text = str(Global.lives)

func update_score_label():
	$SCORE.text = str(Global.player_score)

func update_level_label():
	$LEVEL.text = str(Global.current_level)

func update_ammo_label():
	$AMMO.text = str(Global.ammo)
	
		
func update_face_animation(health):
	var animation_name = ""
	if health > 90:
		animation_name = "100"
	elif health > 75:
		animation_name = "90"
	elif health > 60:
		animation_name = "75"
	elif health > 45:
		animation_name = "60"
	elif health > 30:
		animation_name = "45"
	elif health > 15:
		animation_name = "30"
	else:
		animation_name = "15"
	
	$bj.play(animation_name)
	
