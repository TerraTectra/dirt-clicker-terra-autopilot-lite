## Terra Autopilot Lite: compact, mouse-safe controls above the game version.
## Copyright TerraTectra, 2026. GPL-3.0; see LICENSE and NOTICE.md.
extends Control

signal option_toggled(key: String, enabled: bool)

const GOLD := Color("e4c28a")
const FIRE := Color("f0a576")
const TEXT := Color("f1eee4")
const MUTED := Color("a5afa8")
const WIDTH := 342.0
const FEATURE_DETAILS := {
    "timer": ["Песочные часы", "Останавливает таймер в зоне PERFECT"],
    "minigames": ["Мини-игры", "Решает загадки реликвий"],
    "hats": ["Автошляпы", "Надевает шапки подходящим друзьям"],
    "coffee": ["Автокофе", "Подбирает появившееся кофейное зерно"],
    "relics": ["Автопринятие реликвий", "Открывает реликвии и забирает награду"],
    "chests": ["Автосундуки", "Открывает сундуки, когда есть нужный ключ"],
}

var rows: Dictionary = {}
var _last_state: Array = []
var launcher: Button
var menu: PanelContainer


func _ready() -> void:
    name = "TerraModMenu"
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    z_index = 50
    custom_minimum_size = Vector2(32, 32)
    size = custom_minimum_size
    var font := SystemFont.new()
    font.font_names = PackedStringArray(["Segoe UI", "Arial"])
    add_theme_font_override("font", font)
    launcher = Button.new()
    launcher.name = "MenuButton"
    launcher.size = Vector2(32, 32)
    launcher.toggle_mode = true
    launcher.icon = _menu_icon()
    launcher.tooltip_text = "Настройки Terra Autopilot"
    launcher.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    launcher.add_theme_stylebox_override("normal", _box(Color("171d1bf2"), Color("566052"), 5, 6))
    launcher.add_theme_stylebox_override("hover", _box(Color("303a32"), GOLD, 5, 6))
    launcher.add_theme_stylebox_override("pressed", _box(Color("343c2d"), GOLD, 5, 6))
    launcher.add_theme_stylebox_override("hover_pressed", _box(Color("414733"), GOLD, 5, 6))
    launcher.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), GOLD, 5, 0))
    add_child(launcher)
    launcher.toggled.connect(_on_launcher_toggled)
    menu = PanelContainer.new()
    menu.name = "Options"
    menu.mouse_filter = Control.MOUSE_FILTER_STOP
    menu.custom_minimum_size = Vector2(WIDTH, 0)
    menu.add_theme_stylebox_override("panel", _box(Color("171d1bf8"), Color("566052"), 6, 10))
    add_child(menu)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 5)
    column.mouse_filter = Control.MOUSE_FILTER_IGNORE
    menu.add_child(column)
    var heading := HBoxContainer.new()
    heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
    column.add_child(heading)
    var title := _label("TERRA AUTOPILOT", 14, GOLD)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    heading.add_child(title)
    var close := Button.new()
    close.name = "CloseMenu"
    close.text = "×"
    close.tooltip_text = "Закрыть меню"
    close.custom_minimum_size = Vector2(24, 24)
    close.add_theme_font_size_override("font_size", 18)
    close.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    close.add_theme_stylebox_override("hover", _box(Color("303a32"), GOLD, 3, 0))
    heading.add_child(close)
    close.pressed.connect(close_menu)
    column.add_child(_label("АВТОМАТИЗАЦИЯ", 9, MUTED))
    for key: String in FEATURE_DETAILS:
        _add_row(column, key, FEATURE_DETAILS[key][0], GOLD)
    column.add_child(_label("АВТОПОКУПКА", 9, MUTED))
    _add_row(column, "tools", "Автопокупка магазина", GOLD)
    _add_row(column, "skills", "Автопрокачка", FIRE)
    close_menu()


func _on_launcher_toggled(on: bool) -> void:
    if on:
        open_menu()
    else:
        close_menu()


func open_menu() -> void:
    launcher.set_pressed_no_signal(true)
    menu.show()
    menu.reset_size()
    position_menu(get_viewport().get_visible_rect().size)


func close_menu() -> void:
    if is_instance_valid(menu):
        menu.hide()
    if is_instance_valid(launcher):
        launcher.set_pressed_no_signal(false)


func position_menu(viewport_size: Vector2) -> void:
    if not menu.visible:
        return
    menu.reset_size()
    menu.position = Vector2(minf(0.0, viewport_size.x - global_position.x - menu.size.x - 8.0),
        maxf(8.0 - global_position.y, -menu.size.y - 7.0))


func _input(event: InputEvent) -> void:
    if not is_visible_in_tree() or not menu.visible:
        return
    if event.is_action_pressed("return"):
        close_menu()
        Input.action_release("return")
        get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var local: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
        if not Rect2(Vector2.ZERO, size).has_point(local) and not Rect2(menu.position, menu.size).has_point(local):
            close_menu()
            get_viewport().set_input_as_handled()


func _add_row(parent: Control, key: String, title_text: String, accent: Color) -> void:
    var button := Button.new()
    button.name = key.capitalize()
    button.toggle_mode = true
    button.focus_mode = Control.FOCUS_ALL
    button.custom_minimum_size = Vector2(0, 43)
    button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    button.add_theme_stylebox_override("normal", _box(Color("242c28"), Color("3a443d"), 4, 7))
    button.add_theme_stylebox_override("hover", _box(Color("303a32"), accent.darkened(0.3), 4, 7))
    button.add_theme_stylebox_override("pressed", _box(Color("343c2d"), accent, 4, 7))
    button.add_theme_stylebox_override("hover_pressed", _box(Color("414733"), accent, 4, 7))
    button.add_theme_stylebox_override("disabled", _box(Color("1e2522"), Color("343c36"), 4, 7))
    button.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), accent, 4, 0))
    parent.add_child(button)
    var content := HBoxContainer.new()
    content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    content.offset_left = 7
    content.offset_top = 4
    content.offset_right = -7
    content.offset_bottom = -4
    content.add_theme_constant_override("separation", 4)
    content.mouse_filter = Control.MOUSE_FILTER_IGNORE
    button.add_child(content)
    var check := CheckBox.new()
    check.custom_minimum_size = Vector2(23, 22)
    check.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    check.mouse_filter = Control.MOUSE_FILTER_IGNORE
    check.focus_mode = Control.FOCUS_NONE
    check.add_theme_constant_override("h_separation", 0)
    for state: String in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
        check.add_theme_stylebox_override(state, StyleBoxEmpty.new())
    check.add_theme_icon_override("checked", _check_icon(accent, true, false))
    check.add_theme_icon_override("unchecked", _check_icon(accent, false, false))
    check.add_theme_icon_override("checked_disabled", _check_icon(accent, true, true))
    check.add_theme_icon_override("unchecked_disabled", _check_icon(accent, false, true))
    content.add_child(check)
    var labels := VBoxContainer.new()
    labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    labels.alignment = BoxContainer.ALIGNMENT_CENTER
    labels.add_theme_constant_override("separation", 1)
    labels.mouse_filter = Control.MOUSE_FILTER_IGNORE
    content.add_child(labels)
    var title := _label(title_text, 13, TEXT)
    labels.add_child(title)
    var detail := _label("", 10, MUTED)
    labels.add_child(detail)
    var status := _label("", 9, MUTED)
    status.custom_minimum_size.x = 43
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    content.add_child(status)
    button.toggled.connect(func(on: bool): option_toggled.emit(key, on))
    rows[key] = {"button": button, "check": check, "title": title, "detail": detail,
        "status": status, "accent": accent}


func set_state(tools_unlocked: bool, skills_unlocked: bool, tools_on: bool, skills_on: bool, features: Dictionary = {}) -> void:
    var next: Array = [tools_unlocked, skills_unlocked, tools_on, skills_on, features.duplicate()]
    if _last_state == next:
        return
    _last_state = next
    for key: String in FEATURE_DETAILS:
        _update_row(key, true, bool(features.get(key, true)), "", FEATURE_DETAILS[key][1])
    _update_row("tools", tools_unlocked, tools_on, "Достигните Подземного мира", "Покупает всё: инструменты, друзей, шапки")
    _update_row("skills", skills_unlocked, skills_on, "Достигните Расплавленного мира", "Покупает улучшения за землю")


func _update_row(key: String, unlocked: bool, on: bool, lock_text: String, description: String) -> void:
    var row: Dictionary = rows[key]
    var button: Button = row.button
    button.disabled = not unlocked
    button.set_pressed_no_signal(unlocked and on)
    var check: CheckBox = row.check
    check.disabled = not unlocked
    check.set_pressed_no_signal(unlocked and on)
    row.title.add_theme_color_override("font_color", TEXT if unlocked else MUTED)
    row.detail.text = description if unlocked else lock_text
    row.status.text = ("ВКЛ" if on else "ВЫКЛ") if unlocked else "ЗАКРЫТО"
    row.status.add_theme_color_override("font_color", row.accent if unlocked and on else MUTED)
    button.tooltip_text = (description + ". " + ("Сначала самые дешёвые. " if key in ["tools", "skills"] else "") + "Нажмите, чтобы " +
        ("выключить." if on else "включить.")) if unlocked else lock_text + "."
    if key == "relics":
        button.tooltip_text += "\nРеликвии с загадками открываются при включённых «Мини-играх». Заблокированные предметы не открываются."


func _label(text: String, font_size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return label


func _check_icon(accent: Color, on: bool, locked: bool) -> ImageTexture:
    var icon := Image.create(18, 18, false, Image.FORMAT_RGBA8)
    icon.fill(Color(0, 0, 0, 0))
    var border: Color = Color("566057") if locked else (accent if on else Color("899487"))
    icon.fill_rect(Rect2i(1, 1, 16, 16), border)
    icon.fill_rect(Rect2i(2, 2, 14, 14), Color("343d2d") if on else Color("151c18"))
    if on:
        for point: Vector2i in [Vector2i(4, 8), Vector2i(5, 9), Vector2i(6, 10),
                Vector2i(7, 9), Vector2i(8, 8), Vector2i(9, 7), Vector2i(10, 6), Vector2i(11, 5)]:
            icon.fill_rect(Rect2i(point, Vector2i(2, 2)), accent)
    return ImageTexture.create_from_image(icon)


func _menu_icon() -> ImageTexture:
    var icon := Image.create(18, 18, false, Image.FORMAT_RGBA8)
    icon.fill(Color(0, 0, 0, 0))
    for y: int in [3, 8, 13]:
        icon.fill_rect(Rect2i(1, y, 16, 2), GOLD)
    return ImageTexture.create_from_image(icon)


func _box(background: Color, border: Color, radius: int, padding: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = background
    style.border_color = border
    style.set_border_width_all(1)
    style.set_corner_radius_all(radius)
    style.content_margin_left = padding
    style.content_margin_right = padding
    style.content_margin_top = padding
    style.content_margin_bottom = padding
    return style
