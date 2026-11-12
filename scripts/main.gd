extends Node2D

# Offline single-player prototype. No multiplayer/network code.
const GRAVITY := 9.81
const ENGINE_THRUST := 34.0
const BASE_FUEL := 42.0
const EXTRA_TANK_FUEL := 28.0

var tanks := 1
var engines := 1
var fuel := BASE_FUEL
var altitude := 0.0
var vertical_speed := 0.0
var horizontal_speed := 0.0
var rocket_angle := 0.0
var launched := false
var throttle := false
var turn_left := false
var turn_right := false
var flame_time := 0.0
var status := "Добавь детали и нажми СТАРТ"

var status_label: Label
var stats_label: Label
var fuel_label: Label
var launch_button: Button
var tank_button: Button
var engine_button: Button

func _ready() -> void:
    _create_ui()
    _refresh_ui()
    queue_redraw()

func _create_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(12, 12)
    panel.custom_minimum_size = Vector2(310, 0)
    layer.add_child(panel)
    var col := VBoxContainer.new()
    col.add_theme_constant_override("separation", 5)
    panel.add_child(col)

    var title := Label.new()
    title.text = "SFS BEBEBE • ОДИНОЧНЫЙ РЕЖИМ"
    title.add_theme_font_size_override("font_size", 17)
    col.add_child(title)
    status_label = Label.new()
    status_label.text = status
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.custom_minimum_size.y = 34
    col.add_child(status_label)
    stats_label = Label.new()
    col.add_child(stats_label)

    var build_row := HBoxContainer.new()
    col.add_child(build_row)
    tank_button = Button.new()
    tank_button.text = "+ БАК"
    tank_button.custom_minimum_size = Vector2(100, 44)
    tank_button.pressed.connect(_add_tank)
    build_row.add_child(tank_button)
    engine_button = Button.new()
    engine_button.text = "+ ДВИГАТЕЛЬ"
    engine_button.custom_minimum_size = Vector2(150, 44)
    engine_button.pressed.connect(_add_engine)
    build_row.add_child(engine_button)
    fuel_label = Label.new()
    col.add_child(fuel_label)

    var right := VBoxContainer.new()
    right.anchor_left = 1.0
    right.anchor_right = 1.0
    right.offset_left = -190
    right.offset_right = -12
    right.offset_top = 14
    right.offset_bottom = 185
    layer.add_child(right)
    launch_button = Button.new()
    launch_button.text = "СТАРТ"
    launch_button.custom_minimum_size.y = 52
    launch_button.pressed.connect(_launch)
    right.add_child(launch_button)

    var thrust_button := Button.new()
    thrust_button.text = "УДЕРЖИВАЙ: ТЯГА"
    thrust_button.custom_minimum_size.y = 58
    thrust_button.button_down.connect(func(): throttle = true)
    thrust_button.button_up.connect(func(): throttle = false)
    right.add_child(thrust_button)
    var reset_button := Button.new()
    reset_button.text = "СБРОСИТЬ"
    reset_button.custom_minimum_size.y = 46
    reset_button.pressed.connect(_reset)
    right.add_child(reset_button)

    var steering := HBoxContainer.new()
    steering.anchor_left = 1.0
    steering.anchor_right = 1.0
    steering.anchor_top = 1.0
    steering.anchor_bottom = 1.0
    steering.offset_left = -190
    steering.offset_right = -12
    steering.offset_top = -92
    steering.offset_bottom = -12
    layer.add_child(steering)
    var left_button := Button.new()
    left_button.text = "◀"
    left_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left_button.custom_minimum_size.y = 68
    left_button.button_down.connect(func(): turn_left = true)
    left_button.button_up.connect(func(): turn_left = false)
    steering.add_child(left_button)
    var right_button := Button.new()
    right_button.text = "▶"
    right_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    right_button.custom_minimum_size.y = 68
    right_button.button_down.connect(func(): turn_right = true)
    right_button.button_up.connect(func(): turn_right = false)
    steering.add_child(right_button)

func _add_tank() -> void:
    if launched or tanks >= 4:
        return
    tanks += 1
    fuel += EXTRA_TANK_FUEL
    _refresh_ui()
    queue_redraw()

func _add_engine() -> void:
    if launched or engines >= 3:
        return
    engines += 1
    _refresh_ui()
    queue_redraw()

func _launch() -> void:
    if launched:
        return
    launched = true
    status = "Полёт начат! Удерживай тягу."
    _refresh_ui()

func _reset() -> void:
    tanks = 1
    engines = 1
    fuel = BASE_FUEL
    altitude = 0.0
    vertical_speed = 0.0
    horizontal_speed = 0.0
    rocket_angle = 0.0
    launched = false
    throttle = false
    turn_left = false
    turn_right = false
    status = "Добавь детали и нажми СТАРТ"
    _refresh_ui()
    queue_redraw()

func _physics_process(delta: float) -> void:
    flame_time += delta * 20.0
    if not launched:
        return
    if turn_left:
        rocket_angle = clampf(rocket_angle - delta * 0.8, -0.7, 0.7)
    if turn_right:
        rocket_angle = clampf(rocket_angle + delta * 0.8, -0.7, 0.7)
    var mass := 2.7 + float(tanks) * 0.75 + float(engines) * 0.9 + fuel * 0.035
    var acceleration := 0.0
    if throttle and fuel > 0.0:
        acceleration = ENGINE_THRUST * float(engines) / maxf(mass, 1.0)
        fuel = maxf(0.0, fuel - 7.0 * float(engines) * delta)
    horizontal_speed += sin(rocket_angle) * acceleration * delta
    vertical_speed += (GRAVITY - cos(rocket_angle) * acceleration) * delta
    var drag := clampf(1.0 - (absf(vertical_speed) + absf(horizontal_speed)) * 0.001, 0.90, 1.0)
    horizontal_speed *= drag
    vertical_speed *= drag
    altitude -= vertical_speed * delta
    if altitude < 0.0:
        altitude = 0.0
        vertical_speed = 0.0
        horizontal_speed = 0.0
        launched = false
        throttle = false
        status = "Ракета вернулась на площадку. Нажми СБРОСИТЬ."
    _refresh_ui()
    queue_redraw()

func _refresh_ui() -> void:
    if is_instance_valid(status_label):
        status_label.text = status
        stats_label.text = "Баки: %d   Двигатели: %d\nВысота: %.0f м   Скорость: %.1f м/с" % [tanks, engines, altitude, Vector2(horizontal_speed, vertical_speed).length()]
        fuel_label.text = "Топливо: %.0f / %.0f" % [fuel, BASE_FUEL + float(tanks - 1) * EXTRA_TANK_FUEL]
        tank_button.disabled = launched or tanks >= 4
        engine_button.disabled = launched or engines >= 3
        launch_button.disabled = launched

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color(0.018, 0.026, 0.065))
    var sky_shift := int(minf(altitude * 0.04, 400.0))
    for i in range(90):
        var x := float((i * 137 + 31) % 950)
        var y := float((i * 83 + sky_shift) % 440)
        draw_circle(Vector2(x, y), 1.0 + float(i % 3) * 0.3, Color(0.75, 0.84, 1.0))
    var ground := 460.0 + minf(altitude * 0.04, 80.0)
    if altitude > 1800.0:
        ground = 540.0
    draw_rect(Rect2(0, ground, 960, 100), Color(0.12, 0.19, 0.14))
    draw_line(Vector2(0, ground), Vector2(960, ground), Color(0.38, 0.62, 0.38), 3.0)
    if altitude < 1800.0:
        draw_rect(Rect2(600, ground - 9, 100, 9), Color(0.45, 0.48, 0.54))
    var center := Vector2(650.0 + horizontal_speed * 0.35, 340.0)
    if altitude == 0.0:
        center.y = ground - 55.0
    _draw_rocket(center)
    draw_string(ThemeDB.fallback_font, Vector2(360, 42), "ПОЛЁТНАЯ ЗОНА", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.65, 0.78, 1.0))

func _draw_rocket(center: Vector2) -> void:
    var body_h := 35.0 + float(tanks) * 18.0
    var body_w := 22.0 + float(engines) * 2.0
    var tr := Transform2D(rocket_angle, center)
    var top := -body_h * 0.5
    var bottom := body_h * 0.5
    draw_colored_polygon(PackedVector2Array([tr * Vector2(0, top - 18), tr * Vector2(-body_w * 0.5, top), tr * Vector2(body_w * 0.5, top)]), Color(0.88, 0.22, 0.16))
    draw_colored_polygon(PackedVector2Array([tr * Vector2(-body_w * 0.5, top), tr * Vector2(body_w * 0.5, top), tr * Vector2(body_w * 0.5, bottom), tr * Vector2(-body_w * 0.5, bottom)]), Color(0.79, 0.84, 0.9))
    for i in range(tanks):
        var seam := lerpf(top, bottom, float(i + 1) / float(tanks + 1))
        draw_line(tr * Vector2(-body_w * 0.5, seam), tr * Vector2(body_w * 0.5, seam), Color(0.36, 0.43, 0.52), 2.0)
    draw_circle(tr * Vector2(0, top + 12), 5.0, Color(0.12, 0.48, 0.72))
    draw_colored_polygon(PackedVector2Array([tr * Vector2(-body_w * 0.5, bottom - 10), tr * Vector2(-body_w * 1.1, bottom + 9), tr * Vector2(-body_w * 0.3, bottom + 4)]), Color(0.83, 0.2, 0.16))
    draw_colored_polygon(PackedVector2Array([tr * Vector2(body_w * 0.5, bottom - 10), tr * Vector2(body_w * 1.1, bottom + 9), tr * Vector2(body_w * 0.3, bottom + 4)]), Color(0.83, 0.2, 0.16))
    if throttle and launched and fuel > 0.0:
        var flame_len := 24.0 + fposmod(flame_time, 9.0)
        draw_colored_polygon(PackedVector2Array([tr * Vector2(-7, bottom + 2), tr * Vector2(0, bottom + flame_len), tr * Vector2(7, bottom + 2)]), Color(1.0, 0.55, 0.08))
