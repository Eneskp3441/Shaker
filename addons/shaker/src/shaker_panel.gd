@tool
extends MarginContainer

var _texture_button_play:Button = Button.new()
var _texture_button_stop:Button = Button.new()
var hbox:HBoxContainer = HBoxContainer.new()

const play_texture:CompressedTexture2D = preload("res://addons/shaker/assets/Play.svg")
const pause_texture:CompressedTexture2D = preload("res://addons/shaker/assets/Pause.svg")
const stop_texture:CompressedTexture2D = preload("res://addons/shaker/assets/Stop.svg")

var Target;
var button_width:float = 96;

func _ready() -> void:
	custom_minimum_size.y = 32;
	add_theme_constant_override("margin_left",5)
	add_theme_constant_override("margin_right",5)
	add_theme_constant_override("margin_bottom",5)
	add_theme_constant_override("margin_top",5)
	add_child(hbox)
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_HEIGHT, 5)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER;
	
	hbox.add_child(_texture_button_play)
	_texture_button_play.custom_minimum_size.x = button_width;
	_texture_button_play.expand_icon = true;
	_update_buttons()
	
	hbox.add_child(_texture_button_stop)
	_texture_button_stop.text = "Stop"
	_texture_button_stop.icon = stop_texture;
	_texture_button_stop.custom_minimum_size.x = button_width;
	_texture_button_stop.expand_icon = true;
	
	_texture_button_play.pressed.connect(_on_play_pressed)
	_texture_button_stop.pressed.connect(_on_stop_pressed)
	
	if Target != null:
		Target.timeline_progress.connect(func(progress:float):
			_update_buttons()
		)
		
		Target.shake_finished.connect(func():
			_update_buttons()
		)
	
func _on_play_pressed() -> void:
	Target.play_shake()
	_update_buttons()

func _update_buttons() -> void:
	_texture_button_play.text = "Play" if (Target.timer == 0.0 || !Target.is_playing) else "Pause"
	_texture_button_play.icon = play_texture if (Target.timer == 0.0 || !Target.is_playing) else pause_texture;
	
	_texture_button_stop.text = "Stop" if (!Target._fading_out) else "Force Stop"
	_texture_button_stop.modulate = Color.WHITE if (!Target._fading_out) else Color.INDIAN_RED;
func _on_stop_pressed() -> void:
	if !Target._fading_out:
		Target.stop_shake()
	else:
		Target.force_stop_shake()
	#_update_buttons()
