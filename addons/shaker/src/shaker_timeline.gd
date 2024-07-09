@tool
extends Control

const ShakerBase3d = preload("res://addons/shaker/src/Vector3/ShakerBase3D.gd")
const ShakerBase2d = preload("res://addons/shaker/src/Vector2/ShakerBase2D.gd")

var GRAPH:Panel:
	set=_initalize_graph

var timer:float = 0.0;
var playing:bool = false;
var _shaker_component;

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE;
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_KEEP_SIZE)
	

func _initalize_graph(value:Panel) -> void:
	GRAPH = value;
	if GRAPH != null:
		if GRAPH.shake is ShakerPresetBase:
			_shaker_component = GRAPH.shake.parent;
			if _shaker_component != null:
				_shaker_component.timeline_progress.connect(update_timeline)
				_shaker_component.shake_finished.connect(func():
					if GRAPH.shake is ShakerPresetBase:
						GRAPH.graph_time_offset = 0.0; 
				)
func update_timeline(value=1) -> void:
	timer = value;
	if GRAPH.shake is ShakerPresetBase && _shaker_component != null:
		if GRAPH.shake.__follow_timeline && _shaker_component.is_playing:
			GRAPH.graph_time_offset = max(timer - .5, 0.0)
	queue_redraw()

func _draw() -> void:
	# Playing Timeline 
	var _final_size:Vector2 = size - GRAPH.graph_offset;
	var _timeline_offset:Vector2 = Vector2(-GRAPH.graph_time_offset * _final_size.x, 0.0)
	draw_line(GRAPH.graph_offset+_timeline_offset+Vector2(timer*_final_size.x, 0.0), GRAPH.graph_offset+_timeline_offset+Vector2(timer*_final_size.x, _final_size.y), Color.ORANGE, 1, false)
