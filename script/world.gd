extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		Global.current_level = 2
		call_deferred("_go_next_level")

func _go_next_level():
	get_tree().change_scene_to_file("res://level_2.tscn")
