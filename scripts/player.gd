extends CharacterBody3D

@export var walk_speed: float = 4.0
@export var run_speed: float = 6.5
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var first_person := false
var camera_pitch := 0.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var body_mesh: MeshInstance3D = $BodyMesh

func _ready() -> void:
    if not OS.has_feature("android"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func look_by_drag(delta: Vector2) -> void:
    rotate_y(-delta.x * mouse_sensitivity * 2.0)
    camera_pitch = clamp(camera_pitch - delta.y * mouse_sensitivity * 2.0, -1.1, 1.1)
    camera_pivot.rotation.x = camera_pitch

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        look_by_drag(event.relative)

    if event.is_action_pressed("switch_camera"):
        first_person = not first_person
        spring_arm.spring_length = 0.0 if first_person else 4.0
        body_mesh.visible = not first_person

    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var move_direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()

    var current_speed := run_speed if Input.is_action_pressed("run") else walk_speed
    if move_direction:
        velocity.x = move_direction.x * current_speed
        velocity.z = move_direction.z * current_speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, current_speed)
        velocity.z = move_toward(velocity.z, 0.0, current_speed)

    move_and_slide()
