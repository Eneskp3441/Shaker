@tool
extends EditorNode3DGizmoPlugin

func _init():
	var _color:Color = ProjectSettings.get_setting("debug/shapes/collision/shape_color")
	create_material("EmitterShapeDebug", _color)
	_color.a *= .1
	create_material("EmitterShape", _color)

func _has_gizmo(for_node_3d: Node3D) -> bool:
	return for_node_3d is ShakerEmitter3D

func get_name():
	return "ShakerEmitter3DGizmo"

class EmitterShapeGizmo extends EditorNode3DGizmo:
	var node:ShakerEmitter3D
	
	func _init(node:ShakerEmitter3D) -> void:
		self.node = node
	
	func _redraw():
		var plugin:EditorNode3DGizmoPlugin = get_plugin()
		clear()
		if node.shape:
			add_mesh(node.shape.get_debug_mesh(), plugin.get_material("EmitterShapeDebug", self))
			var mesh:PrimitiveMesh = plugin.get_mesh_by_shape(node.shape)
			if mesh:
				add_mesh(mesh, plugin.get_material("EmitterShape", self))
			
func _create_gizmo(for_node_3d: Node3D) -> EditorNode3DGizmo:
	if for_node_3d is ShakerEmitter3D:
		var _gizmo = EmitterShapeGizmo.new(for_node_3d)
		for_node_3d._gizmo = _gizmo
		return _gizmo
	return null

func get_mesh_by_shape(shape:Shape3D) -> PrimitiveMesh:
	var _mesh:PrimitiveMesh
	if shape is BoxShape3D:
		_mesh = BoxMesh.new()
		_mesh.size = shape.size;
	
	if shape is SphereShape3D:
		_mesh = SphereMesh.new()
		_mesh.radius = shape.radius;
		_mesh.height = shape.radius*2.0;
		_mesh.radial_segments = 16;
		_mesh.rings = 8;
	
	if shape is CapsuleShape3D:
		_mesh = CapsuleMesh.new()
		_mesh.radius = shape.radius;
		_mesh.height = shape.height;
	
	if shape is CylinderShape3D:
		_mesh = CylinderMesh.new()
		_mesh.radius = shape.radius;
		_mesh.height = shape.height;
	
	return _mesh
