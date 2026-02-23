extends Area3D


func _on_body_entered(body):
	# Check if the collided body is the player
	if body.is_in_group("player"):
		Global.last_weapon = "machine"
		Global.current_weapon = "machine"
		queue_free()
