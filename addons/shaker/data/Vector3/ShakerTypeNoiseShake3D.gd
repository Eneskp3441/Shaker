@tool
class_name ShakerTypeNoiseShake3D
extends ShakerTypeBase3D

@export var noise_texture: NoiseTexture3D = NoiseTexture3D.new():
	set = set_noise_texture,
	get = get_noise_texture

func _init() -> void:
	noise_texture.changed.connect(_on_noise_changed)

func get_value(t: float) -> Vector3:
	var result: Vector3 = Vector3.ZERO
	if noise_texture && noise_texture.noise:
		var noise_size: Vector3 = Vector3(noise_texture.width, noise_texture.height, noise_texture.depth)
		var noise_offset: Vector3 = t * noise_size
		result.x = noise_texture.noise.get_noise_3d(noise_offset.x, 0.0, 0.0)
		result.y = noise_texture.noise.get_noise_3d(0.0, noise_offset.y, 0.0)
		result.z = noise_texture.noise.get_noise_3d(0.0, 0.0, noise_offset.z)
		result *= 2.0
	return _calc_value(t, result)

func _on_noise_changed() -> void:
	_on_property_changed("noise_texture")

func set_noise_texture(value: NoiseTexture3D) -> void:
	if noise_texture:
		noise_texture.changed.disconnect(_on_noise_changed)
	noise_texture = value
	if noise_texture:
		noise_texture.changed.connect(_on_noise_changed)

func get_noise_texture() -> NoiseTexture3D:
	return noise_texture
