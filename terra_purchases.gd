## Terra Autopilot Lite: opt-in auto-buy using the game's normal purchase API.
## Copyright TerraTectra, 2026. GPL-3.0; see LICENSE and NOTICE.md.
extends Node

signal option_changed(key: String, enabled: bool)

const PanelView := preload("res://terra_purchase_panel.gd")
const SETTINGS_PATH := "user://terra_autopilot_lite.cfg"
const INTERVAL := 0.35
const FEATURE_DEFAULTS := {"timer": true, "minigames": true, "hats": true, "coffee": true, "relics": true, "chests": true}

var tools_enabled := false
var skills_enabled := false
var tools_unlocked := false
var skills_unlocked := false
var panel: PanelView
var _settings := ConfigFile.new()
var _slot := ""
var _tick := 0.0
var _connected := false
var feature_flags: Dictionary = FEATURE_DEFAULTS.duplicate()


func _ready() -> void:
    process_priority = 1001
    var error := _settings.load(SETTINGS_PATH)
    if error != OK and error != ERR_FILE_NOT_FOUND:
        push_warning("Terra: could not read auto-purchase preferences; using disabled defaults.")


func _process(delta: float) -> void:
    if not GM.is_app_init or not is_instance_valid(GM.ui) or not is_instance_valid(GM.ac):
        return
    if not _connected:
        GM.ac.game_load.on_ready.connect(_on_slot_loaded)
        GM.ac.game_quit.on_ready.connect(_on_slot_closed)
        _connected = true
    if not is_instance_valid(panel):
        panel = PanelView.new()
        GM.ui.overlay.add_child(panel)
        panel.option_toggled.connect(_on_option_toggled)
        panel.visible = false
    if not _run_ready():
        panel.visible = false
        panel.close_menu()
        _tick = 0.0
        return
    # Also supports adding the mod to a build whose startup has already completed.
    if _slot.is_empty():
        _on_slot_loaded()
    refresh_unlocks()
    var top_open: bool = GM.ui.top.is_active
    var skill_view: bool = top_open and GM.ui.top.sub("SKILL_TREE").is_active
    panel.visible = not top_open or skill_view
    if not panel.visible:
        panel.close_menu()
    _update_panel()
    _position_panel()
    _tick -= delta
    if _tick <= 0.0:
        _tick = INTERVAL
        # Settings, dialogs and other overlays do not trigger background spending.
        if (not top_open or skill_view) and not get_tree().paused and not GM.player_input.input_ui_disabled:
            purchase_tick()


func _run_ready() -> bool:
    return (GM.game_state == GM.GameState.PLAYING_RUN and is_instance_valid(GM.wc)
        and GM.wc.world_exists and is_instance_valid(GM.upgrades) and is_instance_valid(GM.data)
        and not GM.ac.game_load.is_running and not GM.ac.game_quit.is_running
        and not GM.ac.world_create.is_running and not GM.ac.world_delete.is_running
        and not GM.ac.run_start.is_running and not GM.ac.run_stop.is_running
        and not GM.ac.prestige_start.is_running)


func _on_slot_loaded() -> void:
    _slot = "slot_" + GM.data.folder_path().sha256_text().left(16)
    tools_enabled = false if GM.is_new_game else bool(_settings.get_value(_slot, "tools", false))
    skills_enabled = false if GM.is_new_game else bool(_settings.get_value(_slot, "skills", false))
    for key: String in FEATURE_DEFAULTS:
        feature_flags[key] = FEATURE_DEFAULTS[key] if GM.is_new_game else bool(_settings.get_value(_slot, key, FEATURE_DEFAULTS[key]))
    tools_unlocked = false
    skills_unlocked = false
    _tick = INTERVAL
    if is_instance_valid(panel):
        panel.close_menu()
    if GM.is_new_game:
        _save_options()


func _on_slot_closed() -> void:
    _slot = ""
    tools_enabled = false
    skills_enabled = false
    tools_unlocked = false
    skills_unlocked = false
    feature_flags = FEATURE_DEFAULTS.duplicate()
    if is_instance_valid(panel):
        panel.close_menu()
        panel.hide()


func refresh_unlocks() -> void:
    # WORLD_* are meta stats in 1.0.1: they survive prestige and world switching.
    # Read them from the current slot instead of granting unlocks across saves.
    var world = GM.wc.world_node_data
    if not is_instance_valid(world):
        tools_unlocked = false
        skills_unlocked = false
        return
    var lava: bool = world.stat_get_value("WORLD_LAVA", 0.0) > 0.0
    var void_world: bool = world.stat_get_value("WORLD_VOID", 0.0) > 0.0
    tools_unlocked = world.stat_get_value("WORLD_CAVE", 0.0) > 0.0 or lava or void_world
    skills_unlocked = lava or void_world


func _on_option_toggled(key: String, enabled: bool) -> void:
    refresh_unlocks()
    if key == "tools":
        tools_enabled = enabled and tools_unlocked
    elif key == "skills":
        skills_enabled = enabled and skills_unlocked
    elif FEATURE_DEFAULTS.has(key):
        feature_flags[key] = enabled
    option_changed.emit(key, enabled)
    _tick = INTERVAL
    _save_options()
    _update_panel()


func option_enabled(key: String) -> bool:
    return bool(feature_flags.get(key, false))


func options_ready() -> bool:
    return not _slot.is_empty()


func _update_panel() -> void:
    if is_instance_valid(panel):
        panel.set_state(tools_unlocked, skills_unlocked, tools_enabled, skills_enabled, feature_flags)


func _save_options() -> void:
    if _slot.is_empty():
        return
    _settings.set_value(_slot, "tools", tools_enabled)
    _settings.set_value(_slot, "skills", skills_enabled)
    for key: String in FEATURE_DEFAULTS:
        _settings.set_value(_slot, key, feature_flags[key])
    if _settings.save(SETTINGS_PATH) != OK:
        push_warning("Terra: auto-purchase choices could not be saved.")


func purchase_tick() -> int:
    if not _run_ready() or get_tree().paused or GM.player_input.input_ui_disabled:
        return 0
    refresh_unlocks()
    var count := 0
    if tools_enabled and tools_unlocked:
        count += _buy_candidate(_cheapest_tool())
    # Rebuild after the first purchase so affordability always uses the new balance.
    if skills_enabled and skills_unlocked and GM.upgrades.has_skill_tree:
        count += _buy_candidate(_cheapest_skill())
    return count


func _eligible(stat) -> bool:
    return (is_instance_valid(stat) and not stat.is_locked and not stat.is_demo_lock
        and not stat.is_max_level() and stat.get_cost_type() == "DIRT"
        and stat.get_cost() >= 0 and GM.player.currency_amount("DIRT") >= stat.get_cost())


func _cheapest_tool() -> Dictionary:
    var best: Dictionary = {}
    for item in GM.ui.shop.all_btns:
        if not _shop_entry_eligible(item):
            continue
        var stat = item.stat_count
        if _eligible(stat) and (best.is_empty() or stat.get_cost() < best.stat.get_cost()):
            best = {"node": item.node_key, "key": "COUNT", "id": 0, "stat": stat}
    return best


func _shop_entry_eligible(item) -> bool:
    if not is_instance_valid(item) or not item.is_setup:
        return false
    var data = item.node_data
    return (is_instance_valid(data) and not data.is_stat_count_max()
        and data.stat_get_value("SHOP_UNLOCK", 1.0) == 1.0 and _eligible(item.stat_count))


func _cheapest_skill() -> Dictionary:
    var best: Dictionary = {}
    for button in GM.upgrades.ui_skill_tree.btns:
        if not is_instance_valid(button) or button.type != UIBtnSkillTree.Type.SKILL_TREE:
            continue
        var stat = button.stat_data
        # Only the normal skill tree, never prestige/world/sand currencies or shop counts.
        if button.key_stat == "COUNT" or not _eligible(stat):
            continue
        if best.is_empty() or stat.get_cost() < best.stat.get_cost():
            best = {"node": button.key_node, "key": button.key_stat, "id": button.stat_id, "stat": stat}
    return best


func _buy_candidate(candidate: Dictionary) -> int:
    if candidate.is_empty() or not _eligible(candidate.stat):
        return 0
    var before: int = candidate.stat.level
    GM.upgrades._on_purchase_request(false, candidate.node, candidate.key, candidate.id)
    return 1 if candidate.stat.level > before else 0


func _position_panel() -> void:
    var version: Label = GM.ui.version
    if not is_instance_valid(version):
        return
    var anchor: Vector2 = GM.ui.overlay.get_global_transform().affine_inverse() * version.global_position
    var viewport_size: Vector2 = GM.ui.base.size
    panel.position = Vector2(clampf(anchor.x, 8.0, maxf(8.0, viewport_size.x - panel.size.x - 8.0)),
        maxf(8.0, anchor.y - panel.size.y - 8.0))
    panel.position_menu(viewport_size)
