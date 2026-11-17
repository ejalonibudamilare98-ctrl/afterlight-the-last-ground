extends Node2D

# Simple on-screen controls for Android: left joystick, jump/run buttons,
# and drag-to-look on the right side of the screen.
const STICK_RADIUS := 76.0
const STICK_DEADZONE := 12.0
var stick_touch := -1
var jump_touch := -1
var run_touch := -1
var look_touch := -1
var stick_vector := Vector2.ZERO
var player: CharacterBody3D

func _ready() -> void:
    player = get_parent().get_node("Player")
    queue_redraw()

func _draw() -> void:
    var size := get_viewport_rect().size
    var base := Vector2(115.0, size.y - 125.0)
    draw_circle(base, STICK_RADIUS, Color(0.08, 0.08, 0.08, 0.42))
    draw_arc(base, STICK_RADIUS, 0.0, TAU, 48, Color(1, 1, 1, 0.55), 3.0)
    draw_circle(base + stick_vector * 48.0, 30.0, Color(0.85, 0.85, 0.85, 0.62))
    var jump_pos := Vector2(size.x - 92.0, size.y - 145.0)
    var run_pos := Vector2(size.x - 205.0, size.y - 105.0)
    draw_circle(jump_pos, 43.0, Color(0.12, 0.48, 0.85, 0.72))
    draw_circle(run_pos, 35.0, Color(0.18, 0.18, 0.18, 0.72))
    draw_string(ThemeDB.fallback_font, jump_pos + Vector2(-18, 6), "JUMP", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
    draw_string(ThemeDB.fallback_font, run_pos + Vector2(-16, 5), "RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _start_touch(event.index, event.position)
        else:
            _end_touch(event.index)
    elif event is InputEventScreenDrag:
        if event.index == stick_touch:
            _update_stick(event.position)
        elif player and event.index != jump_touch and event.index != run_touch and event.position.x >= get_viewport_rect().size.x * 0.45:
            player.look_by_drag(event.relative)
    elif event is InputEventScreenTouch and not event.pressed:
        queue_redraw()

func _start_touch(index: int, pos: Vector2) -> void:
    var size := get_viewport_rect().size
    var jump_pos := Vector2(size.x - 92.0, size.y - 145.0)
    var run_pos := Vector2(size.x - 205.0, size.y - 105.0)
    if pos.distance_to(jump_pos) < 58.0:
        jump_touch = index
        Input.action_press("jump")
    elif pos.distance_to(run_pos) < 48.0:
        run_touch = index
        Input.action_press("run")
    elif pos.x < size.x * 0.45 and pos.y > size.y * 0.45 and stick_touch == -1:
        stick_touch = index
        _update_stick(pos)
    elif pos.x >= size.x * 0.45 and look_touch == -1:
        look_touch = index

func _update_stick(pos: Vector2) -> void:
    var size := get_viewport_rect().size
    var base := Vector2(115.0, size.y - 125.0)
    stick_vector = (pos - base).limit_length(STICK_RADIUS) / STICK_RADIUS
    if stick_vector.length() < STICK_DEADZONE / STICK_RADIUS:
        stick_vector = Vector2.ZERO
    _set_action("move_left", stick_vector.x < -0.25)
    _set_action("move_right", stick_vector.x > 0.25)
    _set_action("move_forward", stick_vector.y < -0.25)
    _set_action("move_back", stick_vector.y > 0.25)
    queue_redraw()

func _end_touch(index: int) -> void:
    if index == stick_touch:
        stick_touch = -1
        stick_vector = Vector2.ZERO
        for action in ["move_left", "move_right", "move_forward", "move_back"]:
            Input.action_release(action)
        queue_redraw()
    if index == jump_touch:
        jump_touch = -1
        Input.action_release("jump")
    if index == run_touch:
        run_touch = -1
        Input.action_release("run")
    if index == look_touch:
        look_touch = -1

func _set_action(action: String, active: bool) -> void:
    if active:
        if not Input.is_action_pressed(action):
            Input.action_press(action)
    else:
        Input.action_release(action)
