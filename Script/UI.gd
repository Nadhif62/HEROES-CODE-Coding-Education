extends Control

signal speed_changed(new_speed)

var pause_scene = preload("res://Scene/Pause.tscn")
var pause_instance

var bg_normal = preload("res://Assets/UI/TextBox.png")
var bg_expanded = preload("res://Assets/UI/TextBoxSwipeUp.png")

var margin_top_normal = 160
var margin_top_expanded = 180

var speeds = [1, 2, 3]
var current_speed_index = 0
var speed_textures = [
	preload("res://Assets/UI/SpeedUpx1.png"),
	preload("res://Assets/UI/SpeedUpx2.png"),
	preload("res://Assets/UI/SpeedUpx3.png")
]

var is_expanded = false

var start_pos_y = 0
var start_height = 0

onready var text_box = $TextureRect/TextEdit
onready var run_button = $RunButton
onready var stop_button = $StopButton
onready var speed_button = $SpeedUpButton
onready var speed_texture_rect = $SpeedUpButton/TextureRect
onready var pause_button = $PauseButton
onready var player = get_parent().get_node("YSort/Player")

onready var panel_bg = $TextureRect
onready var expand_button = $TextureRect/ExpandButton

onready var sfx_click = $SFXClick

func _ready():
	pause_instance = pause_scene.instance()
	add_child(pause_instance)
	pause_instance.visible = false
	pause_instance.pause_mode = Node.PAUSE_MODE_PROCESS

	if run_button:
		run_button.connect("pressed", self, "_on_run_pressed")
	
	if stop_button:
		stop_button.connect("pressed", self, "_on_stop_pressed")

	if speed_button:
		if speed_texture_rect:
			speed_texture_rect.texture = speed_textures[0]
		speed_button.connect("pressed", self, "_on_speed_pressed")

	if pause_button:
		pause_button.connect("pressed", self, "_on_pause_pressed")
		
	if player:
		if not player.is_connected("completed", self, "_on_player_completed"):
			player.connect("completed", self, "_on_player_completed")
	
	if expand_button:
		expand_button.connect("pressed", self, "_on_expand_pressed")

	set_process_input(true)
	
	if panel_bg:
		panel_bg.texture = bg_normal
		start_pos_y = panel_bg.rect_position.y
		start_height = panel_bg.rect_size.y
		panel_bg.expand = true
		panel_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		if text_box:
			text_box.margin_top = margin_top_normal

func _on_expand_pressed():
	if not panel_bg: return
	sfx_click.play()
	
	is_expanded = !is_expanded
	
	if is_expanded:
		panel_bg.texture = bg_expanded
		
		var ratio = bg_expanded.get_height() / float(bg_expanded.get_width())
		var new_height = panel_bg.rect_size.x * ratio
		panel_bg.rect_size.y = new_height
		
		var diff = new_height - start_height
		panel_bg.rect_position.y = start_pos_y - diff
		
		if text_box:
			text_box.margin_top = margin_top_expanded
		
	else:
		panel_bg.texture = bg_normal
		
		panel_bg.rect_size.y = start_height
		panel_bg.rect_position.y = start_pos_y
		
		if text_box:
			text_box.margin_top = margin_top_normal

func _input(event):
	if not text_box.has_focus(): return

	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER:
			_handle_enter_key()
			get_tree().set_input_as_handled()
		elif event.scancode == KEY_TAB:
			_handle_tab_key()
			get_tree().set_input_as_handled()
		elif event.unicode == 123: 
			_handle_open_brace()
			get_tree().set_input_as_handled()
		elif event.unicode == 40:
			_handle_parentheses()
			get_tree().set_input_as_handled()

func _handle_enter_key():
	var cursor_line = text_box.cursor_get_line()
	var cursor_col = text_box.cursor_get_column()
	var current_line_text = text_box.get_line(cursor_line)
	var indentation = _get_indentation(current_line_text)
	
	if current_line_text.strip_edges().ends_with("{") and cursor_col >= current_line_text.length():
		indentation += "    "
		
	text_box.insert_text_at_cursor("\n" + indentation)

func _handle_tab_key():
	var cursor_line = text_box.cursor_get_line()
	var cursor_col = text_box.cursor_get_column()
	var current_line_text = text_box.get_line(cursor_line)
	var text_before_cursor = current_line_text.substr(0, cursor_col)
	var regex = RegEx.new()
	regex.compile("^\\s*$")
	if regex.search(text_before_cursor):
		text_box.insert_text_at_cursor("    ")

func _handle_open_brace():
	var cursor_line = text_box.cursor_get_line()
	var current_line_text = text_box.get_line(cursor_line)
	var indentation = _get_indentation(current_line_text)
	var text_to_insert = "{\n" + indentation + "    \n" + indentation + "}"
	text_box.insert_text_at_cursor(text_to_insert)
	text_box.cursor_set_line(cursor_line + 1)
	text_box.cursor_set_column(indentation.length() + 4)

func _handle_parentheses():
	text_box.insert_text_at_cursor("()")
	text_box.cursor_set_column(text_box.cursor_get_column() - 1)

func _get_indentation(line_text):
	var regex = RegEx.new()
	regex.compile("^\\s*")
	var result = regex.search(line_text)
	if result: return result.get_string()
	return ""

func set_run_button_enabled(enabled):
	if run_button:
		run_button.disabled = !enabled
		if enabled:
			run_button.modulate = Color(1, 1, 1, 1)
		else:
			run_button.modulate = Color(0.5, 0.5, 0.5, 1)

func _on_run_pressed():
	sfx_click.play()
	player.text_edit = text_box
	if player.has_method("run_script"):
		set_run_button_enabled(false)
		player.run_script()
		if is_expanded: _on_expand_pressed()

func _on_stop_pressed():
	sfx_click.play()
	if player.has_method("reset_script"):
		player.reset_script()
		set_run_button_enabled(true)

func _on_player_completed():
	set_run_button_enabled(true)

func _on_speed_pressed():
	sfx_click.play()
	current_speed_index = (current_speed_index + 1) % speed_textures.size()
	if speed_texture_rect:
		speed_texture_rect.texture = speed_textures[current_speed_index]
	emit_signal("speed_changed", speeds[current_speed_index])

func _on_pause_pressed():
	if pause_instance.has_method("open_pause"):
		pause_instance.open_pause()
	else:
		pause_instance.visible = true
		get_tree().paused = true
