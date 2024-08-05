extends Node3D
@onready var character_body_3d: CharacterBody3D = $"../CharacterBody3D"
@onready var shaker_component_3d: ShakerComponent3D = $"../CharacterBody3D/ShakerComponent3D"
@onready var mesh_instance_3d_4: MeshInstance3D = $MeshInstance3D4

var STRONG_SHAKE_3D = preload("res://addons/shaker/data/resources/strong_shake3D.tres")
var intensity:float = 1.0
@onready var label_3d: Label3D = $Label3D
var text:String = "
Press R for strong shake
Press T for shake the cube
Q-E Intensity: %s"

var ShakerScript = preload("res://addons/shaker/src/Shaker.gd").new()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_T:
			# You do not need to load the script if the plugin is active, use "Shaker" directly
			# Shaker.shake_by_preset(...
			ShakerScript.shake_by_preset(STRONG_SHAKE_3D, mesh_instance_3d_4, 1.0, 1.0, intensity)
		if event.keycode == KEY_R:
			shaker_component_3d.shake(STRONG_SHAKE_3D, ShakerComponent3D.ShakeAddMode.add, 1.0, 1.0, intensity)
		if event.keycode == KEY_Q:
			intensity -= .25
			intensity = max(intensity, 0.0)
		if event.keycode == KEY_E:
			intensity += .25
		
		label_3d.text = text % intensity
