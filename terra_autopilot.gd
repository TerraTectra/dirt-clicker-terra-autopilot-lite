## Terra's minimal Dirt Clicker minigame automation.
## Logic adapted from Dirt Autopilot by eyyMinda (GPL-3.0).
## Automates Sand Mines PERFECT, relic puzzles, suitable hats, and coffee beans.
extends Node

const TIMER_STOP_AT_SEC := 0.05
const MG_ANSWER_DELAY_MSEC := 200
const HAT_DELAY_MSEC := 600
const HAT_POLL_SEC := 0.1
const RELIC_OPEN_SEC := 1.0
const RELIC_ACTION := "TERRA_RELIC_AUTO_OPEN"
const Hats := preload("res://terra_hats.gd")
const Purchases := preload("res://terra_purchases.gd")

var _mg_scene: Node = null
var _mg_answer_at_msec := 0
var _hat_at_msec := 0
var _hat_tick_t := 0.0
var _credit_names: Array[String] = []
var purchases: Purchases
var _relic_popup_key := ""
var _relic_accept_at := 0
var _relic_open_stack: ItemStack

func _ready() -> void:
    process_priority = 1000
    purchases = Purchases.new()
    purchases.name = "Purchases"
    add_child(purchases)
    purchases.option_changed.connect(_on_mod_option_changed)
    print("TERRA_AUTOPILOT_ACTIVE")

func _process(_delta: float) -> void:
    if not GM.is_app_init or GM.game_state != GM.GameState.PLAYING_RUN or not is_instance_valid(purchases):
        _cancel_relic_open()
        return
    if not purchases.options_ready() or GM.ac.game_load.is_running or GM.ac.game_quit.is_running:
        _cancel_relic_open()
        return
    _repair_world_input()
    if purchases.option_enabled("timer"):
        _play_timer_game()
    if purchases.option_enabled("minigames"):
        _solve_relic_minigame()
    else:
        _mg_scene = null
    _hat_tick_t -= _delta
    if _hat_tick_t <= 0.0:
        _hat_tick_t = HAT_POLL_SEC
        if purchases.option_enabled("hats"):
            _place_hat()
        else:
            _hat_at_msec = 0
        if purchases.option_enabled("coffee"):
            _grab_coffee()
        if purchases.option_enabled("chests"):
            _open_chests()
        if purchases.option_enabled("relics"):
            _accept_relic_reward()
            _open_inventory_relic()
        else:
            _relic_popup_key = ""
            _cancel_relic_open()


func _world_interaction_ready() -> bool:
    return (purchases._run_ready() and not get_tree().paused
        and not GM.player_input.input_ui_disabled and not GM.ui.top.is_active
        and not GM.ui.options.is_active and not GM.ui.hat_mode.is_active
        and not GM.dialog.in_action and not GM.mini_games.playing
        and not GM.badges.ui_reward_active)


## A deferred modal release can arrive after the game's per-run counter reset.
## Negative counts block every world click. Repair only that invalid state;
## positive locks still belong to the game, including an opening chest.
func _repair_world_input() -> void:
    if not _world_interaction_ready():
        return
    var selector = GM.wc.selectable
    if is_instance_valid(selector) and selector.input_disabled < 0:
        selector.input_disabled = 0
        selector._calculate_hover_priority()


## Adapted from eyyMinda's chest opener (GPL-3.0). Use normal keys, animations
## and rewards; an existing key also works when the chest appears later.
func _open_chests() -> void:
    if not _world_interaction_ready() or not is_instance_valid(GM.chest):
        return
    if GM.wc.selectable.input_disabled != 0 or not is_instance_valid(GM.wc.world):
        return
    var available: Array[ChestWorld] = []
    for node in GM.wc.world.y_depth.get_children():
        if not node is ChestWorld or node.is_queued_for_deletion():
            continue
        var chest: ChestWorld = node
        # Serialize the whole animation/reward/close sequence, including manual opens.
        if chest.ap.is_playing():
            return
        if GM.chest.chest_is_opened(chest.type) or not chest.is_visible_in_tree():
            continue
        if chest.key_badge_unlocked_by.is_empty():
            continue
        var owns_key: bool = GM.badges.badge_is_own(chest.key_badge_unlocked_by)
        if chest.is_unlocked != owns_key:
            chest.set_unlock_state(owns_key)
        if owns_key:
            available.append(chest)
    if not available.is_empty():
        GM.chest.chest_input(available[0])


func _on_mod_option_changed(key: String, enabled: bool) -> void:
    if key == "relics" and not enabled:
        _relic_popup_key = ""
        _cancel_relic_open()
    elif key == "minigames" and not enabled and is_instance_valid(_relic_open_stack):
        if is_instance_valid(GM.inv) and GM.inv.item_is_game(_relic_open_stack.key):
            _cancel_relic_open()


## Adapted from eyyMinda's inventory relic opener (GPL-3.0).
## Use the normal one-second hold action, one inventory stack at a time.
func _open_inventory_relic() -> void:
    if not is_instance_valid(GM.inv) or not purchases._run_ready() or get_tree().paused:
        return
    if (GM.mini_games.playing or GM.badges.ui_reward_active or GM.ui.top.is_active
        or GM.player_input.input_ui_disabled):
        return
    for stack: ItemStack in GM.inv.item_stacks:
        if stack.is_relic and is_instance_valid(stack.action_load) and stack.action_load.is_running:
            return
    _relic_open_stack = null
    for stack: ItemStack in GM.inv.item_stacks:
        if (not stack.is_relic or stack.is_locked or stack.amount <= 0
            or not is_instance_valid(stack.ui_item) or not is_instance_valid(stack.action_load)):
            continue
        if GM.inv.item_is_game(stack.key) and not purchases.option_enabled("minigames"):
            continue
        # The game's UI processes for one more frame after a consumed stack is removed.
        # Stop that icon before ItemStack clears action_load, avoiding a null access.
        if not stack.has_meta("terra_relic_ui_guard"):
            stack.set_meta("terra_relic_ui_guard", true)
            stack.on_deleted.connect(stack.ui_item.set_process.bind(false), CONNECT_ONE_SHOT)
        _relic_open_stack = stack
        stack.action_load.set_type(RELIC_ACTION).set_sell_amount(0) \
            .set_particles_pos(stack.ui_item.pos_mid / 2.0).set_time(RELIC_OPEN_SEC).start_timer()
        return


func _cancel_relic_open() -> void:
    if is_instance_valid(_relic_open_stack) and is_instance_valid(_relic_open_stack.action_load):
        var action = _relic_open_stack.action_load
        if action.is_running and action.type == RELIC_ACTION:
            action.cancel()
    _relic_open_stack = null


## Confirm an already-granted relic reward through the normal Continue action.
## Inventory activation is handled separately; achievement rewards remain manual.
func _accept_relic_reward() -> void:
    if not is_instance_valid(GM.badges) or not GM.badges.ui_reward_active:
        _relic_popup_key = ""
        return
    var popup = GM.badges.ui_badge_unlock
    if not is_instance_valid(popup) or not is_instance_valid(popup.badge_icon):
        return
    var key: String = popup.badge_icon.badge_key
    if key.is_empty() or not GM.badges.badge_exists(key) or GM.badges.badge_is_meta(key):
        _relic_popup_key = ""
        return
    var now := Time.get_ticks_msec()
    if _relic_popup_key != key:
        _relic_popup_key = key
        _relic_accept_at = now + 350
    elif now >= _relic_accept_at:
        _relic_popup_key = ""
        GM.badges.input_close()

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
