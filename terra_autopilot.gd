## Terra's minimal Dirt Clicker minigame automation.
## Logic adapted from Dirt Autopilot by eyyMinda (GPL-3.0).
## Automates Sand Mines PERFECT, relic puzzles, suitable hats, and coffee beans.
extends Node

const TIMER_STOP_AT_SEC := 0.05
const MG_ANSWER_DELAY_MSEC := 200
const HAT_DELAY_MSEC := 600
const HAT_POLL_SEC := 0.1
const Hats := preload("res://terra_hats.gd")

var _mg_scene: Node = null
var _mg_answer_at_msec := 0
var _hat_at_msec := 0
var _hat_tick_t := 0.0
var _credit_names: Array[String] = []

func _ready() -> void:
    process_priority = 1000
    print("TERRA_AUTOPILOT_ACTIVE")

func _process(_delta: float) -> void:
    if not GM.is_app_init or not GM.is_playing():
        return
    _play_timer_game()
    _solve_relic_minigame()
    _hat_tick_t -= _delta
    if _hat_tick_t <= 0.0:
        _hat_tick_t = HAT_POLL_SEC
        _place_hat()
        _grab_coffee()

func _play_timer_game() -> void:
    if not is_instance_valid(GM.sand):
        return
    var g: SandGameController = GM.sand.game
    if not is_instance_valid(g):
        return
    if g.playing:
        if g.sm_game_state == SandGameController.GameState.TIMER_RUNNING and g.time_sec_left <= TIMER_STOP_AT_SEC:
            g.timer_input_stop()
    elif g.playable and GM.sand.is_unlocked:
        g.game_start()

func _solve_relic_minigame() -> void:
    if not is_instance_valid(GM.mini_games) or not GM.mini_games.playing:
        _mg_scene = null
        return
    var mg: UIMiniGame = GM.mini_games.current_ui_scene
    if not is_instance_valid(mg) or mg.won or mg.answer_correct.is_empty():
        return
    var now := Time.get_ticks_msec()
    if _mg_scene != mg:
        _mg_scene = mg
        _mg_answer_at_msec = now + MG_ANSWER_DELAY_MSEC
    if now >= _mg_answer_at_msec and not mg.input_locked:
        mg.line_edit.text = mg.answer_correct
        mg._request_answer_check(mg.answer_correct)

## Uses the hat picker's own selection and confirmation functions, the same
## strategy as Dirt Autopilot by eyyMinda (GPL-3.0).
## Picks an unhatted, eligible pal, without replacing an existing hat.
func _place_hat() -> void:
    if not is_instance_valid(GM.hat) or not is_instance_valid(GM.ui):
        return
    var hm = GM.ui.hat_mode
    var que: Array[String] = GM.hat.hats_que
    if not is_instance_valid(hm) or not hm.is_active or que.is_empty():
        _hat_at_msec = 0
        return
    var now := Time.get_ticks_msec()
    if _hat_at_msec == 0:
        _hat_at_msec = now + HAT_DELAY_MSEC
    if now < _hat_at_msec:
        return
    # Never interrupt a name currently being typed by the player.
    if hm.line_edit.has_focus():
        return

    var free := {}
    for sel in hm.all_selections:
        if not is_instance_valid(sel) or sel.is_queued_for_deletion() or sel.is_disabled:
            continue
        if not is_instance_valid(sel.node_world) or sel.node_world.hat_enabled:
            continue
        var pal: String = sel.node_world.node_data.key
        if not free.has(pal):
            free[pal] = sel

    for i in que.size():
        for pal in Hats.pal_order(que[i], Hats.BEST_FIT):
            if not free.has(pal):
                continue
            _hat_at_msec = now + HAT_DELAY_MSEC
            if i > 0:
                # Only the first queued hat can be equipped in this picker.
                for _n in i:
                    que.push_back(que.pop_front())
                hm.toggle_start()
                return
            free[pal].on_pressed.emit()
            if hm.line_edit.text.strip_edges().is_empty():
                hm.line_edit.text = _new_pal_name()
            hm.toggle_confirm()
            return

func _new_pal_name() -> String:
    if _credit_names.is_empty():
        _credit_names = Hats.credit_names()
    var taken := {}
    for guy in get_tree().get_nodes_in_group("GUY"):
        if not str(guy.nametag).is_empty():
            taken[str(guy.nametag).to_upper()] = true
    return Hats.pick_name(taken, _credit_names)

## Use the game's own bean interaction; never move or click the mouse.
## Adapted from eyyMinda's Dirt Autopilot (GPL-3.0).
func _grab_coffee() -> void:
    if not is_instance_valid(GM.coffee) or not GM.coffee.bean_is_active or GM.coffee.effect_is_active:
        return
    var ui_coffee = GM.ui.coffee
    if not is_instance_valid(ui_coffee):
        return
    var bean: UICoffeeBean = ui_coffee.coffee_bean
    if is_instance_valid(bean) and bean.is_active and not bean.is_clicked:
        bean._on_pressed()
