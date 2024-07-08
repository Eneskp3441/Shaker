extends Node3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var gpu_particles_3d_2: GPUParticles3D = $GPUParticles3D2
@onready var shaker_emitter_3d: ShakerEmitter3D = $ShakerEmitter3D

func _ready() -> void:
	gpu_particles_3d.emitting = true
	gpu_particles_3d_2.emitting = true
	shaker_emitter_3d.play_shake()
	gpu_particles_3d.finished.connect(func():
		call_deferred("queue_free")
	)
