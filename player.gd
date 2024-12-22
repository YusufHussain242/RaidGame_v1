extends CharacterBody3D


@export var speed := 5
@export var jump_velocity := 4.5
@export var mouse_speed := 0.1

@onready var mount: Node3D = $mount

var camera_rot := Vector2(0, 0)
var mouse_delta := Vector2(0, 0)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	update_velocity(delta)
	update_rotation(delta)
	move_and_slide()
	
func update_rotation(delta: float) -> void:
	camera_rot -= mouse_delta * delta * mouse_speed
	camera_rot.y = clampf(camera_rot.y, -1, 1)
	mouse_delta = Vector2(0, 0)
	
	transform.basis = Basis()
	mount.basis = Basis()
	rotate_object_local(Vector3(0, 1, 0), camera_rot.x)
	mount.rotate_object_local(Vector3(1, 0, 0), camera_rot.y)
	
func update_velocity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta.x = event.relative.x
		mouse_delta.y = event.relative.y
