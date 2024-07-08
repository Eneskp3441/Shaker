@tool
class_name ShakerTypeNoiseShake2D
extends ShakerTypeBase2D

@export var noise_texture: NoiseTexture2D = NoiseTexture2D.new():
	set = set_noise_texture,
	get = get_noise_texture

func _init() -> void:
	noise_texture.changed.connect(_on_noise_changed)

func get_value(t: float) -> Vector2:
	var result: Vector2 = Vector2.ZERO
	if noise_texture && noise_texture.noise:
		var noise_size: Vector2 = Vector2(noise_texture.width, noise_texture.height)
		var noise_offset: Vector2 = t * noise_size
		result.x = noise_texture.noise.get_noise_2d(noise_offset.x, 0.0)
		result.y = noise_texture.noise.get_noise_2d(0.0, noise_offset.y)
		result *= 2.0
	return _calc_value(t, result)

func _on_noise_changed() -> void:
	_on_property_changed("noise_texture")

func set_noise_texture(value: NoiseTexture2D) -> void:
	if noise_texture:
		noise_texture.changed.disconnect(_on_noise_changed)
	noise_texture = value
	if noise_texture:
		noise_texture.changed.connect(_on_noise_changed)

func get_noise_texture() -> NoiseTexture2D:
	return noise_texture
