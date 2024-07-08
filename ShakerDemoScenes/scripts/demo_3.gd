extends Node3D

var timer:float = 0.0
const EXPLOSION = preload("res://ShakerDemoScenes/Scenes/explosion.tscn")
@onready var explosion: Node3D = $Explosion

func _process(delta: float) -> void:
	timer += delta
	if timer > 1.0:
		var exp = EXPLOSION.instantiate()
		explosion.add_child(exp)
		timer = 0.0
