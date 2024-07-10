@tool
class_name ShakerTypeAudioBus1D
extends ShakerTypeBase1D

@export var bus_name:String = "Master":
	set = set_bus_name,
	get = get_bus_name
@export_range(20, 20000) var min_frequence:float = 20
@export_range(20, 20000) var max_frequence:float = 20000

var bus_index:int = 0
var effect:AudioEffectSpectrumAnalyzerInstance

## Calculates the value of the square wave at time t.
func get_value(t: float) -> float:
	var result:float = 0.0
	if effect:
		var mag:Vector2 = effect.get_magnitude_for_frequency_range(min_frequence, max_frequence, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX)
		result = mag.length()
	return _calc_value(t, result)

func set_bus_name(value: String) -> void:
	bus_name = value
	_update_bus_index()
	_on_property_changed("bus_name")

func get_bus_name() -> String:
	return bus_name

func _update_bus_index() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index > -1:
		for e in AudioServer.get_bus_effect_count(bus_index):
			var _effect:AudioEffect = AudioServer.get_bus_effect(bus_index, e)
			if _effect is AudioEffectSpectrumAnalyzer:
				effect = AudioServer.get_bus_effect_instance(bus_index, e, 0)
				break;
		if effect == null:
			AudioServer.add_bus_effect(bus_index, AudioEffectSpectrumAnalyzer.new(), 0)
			effect = AudioServer.get_bus_effect_instance(bus_index, 0)
	else:
		push_error("Error: Bus '" + bus_name + "' not found!")
		effect = null
