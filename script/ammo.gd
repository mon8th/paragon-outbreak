extends Area3D


func _on_body_entered(body):
	if body.is_in_group("player"):
		Global.ammo += 10  
		print(Global.ammo)
		Global.current_weapon = Global.last_weapon
		queue_free()
