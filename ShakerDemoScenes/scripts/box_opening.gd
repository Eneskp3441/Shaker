extends Node3D
@onready var shaker_component_3d: ShakerComponent3D = $ShakerComponent3D

func _process(_delta: float) -> void:
	if !shaker_component_3d.is_playing:
		shaker_component_3d.play_shake()
