extends Area3D

func _on_body_entered(body):
	# Check if the collided body is the player
	if body.is_in_group("player"):
		# Increase the player health by 25, but do not exceed 100
		Global.player_health = min(Global.player_health + 25, 100)
		print(Global.player_health)
		# Queue the ammo object for deletion
		queue_free()
