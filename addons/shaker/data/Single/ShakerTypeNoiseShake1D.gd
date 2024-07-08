@tool
class_name ShakerTypeNoiseShake1D
extends ShakerTypeBase1D

@export var noise_texture: NoiseTexture2D = NoiseTexture2D.new():
	set = set_noise_texture,
	get = get_noise_texture

func _init() -> void:
	noise_texture.changed.connect(_on_noise_changed)

func get_value(t: float) -> float:
	var result:float = 0.0
	if noise_texture && noise_texture.noise:
		var noise_size:Vector2 = Vector2(noise_texture.width, noise_texture.height)
		var noise_offset:float = t * noise_size.x
		result = noise_texture.noise.get_noise_1d(noise_offset)
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
