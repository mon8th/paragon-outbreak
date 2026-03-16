extends CanvasLayer

@onready var restart_button: Button = $Panel/Restart
@onready var panel: Panel = $Panel
@onready var color_rect: ColorRect = $Panel/ColorRect
@onready var gameover_label = $Panel/gameover

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gameover_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS

	if not restart_button.pressed.is_connected(_on_pressed):
		restart_button.pressed.connect(_on_pressed)

func show_game_over():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	restart_button.grab_focus()

func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		print("KEY RESTART WORKED")
		_on_pressed()

func _on_pressed():
	print("RESTART BUTTON CLICKED")
	Global.player_health = 100
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()
