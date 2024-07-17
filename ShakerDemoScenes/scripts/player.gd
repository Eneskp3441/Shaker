extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2
@onready var camera_3d: Camera3D = $Camera3D
@onready var shaker_component_3d:ShakerComponent3D = $ShakerComponent3D
var HEAD_BOB_WALKING = preload("res://ShakerDemoScenes/HeadBobWalking.tres")
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		HEAD_BOB_WALKING.amplitude = HEAD_BOB_WALKING.amplitude.move_toward(Vector3(0.02, 0.01, 0.02), delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		HEAD_BOB_WALKING.amplitude = HEAD_BOB_WALKING.amplitude.move_toward(Vector3.ZERO, delta)

	move_and_slide()
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y += -event.relative.x * .5
		camera_3d.rotation_degrees.x -= event.relative.y * .5
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -90, 65)
