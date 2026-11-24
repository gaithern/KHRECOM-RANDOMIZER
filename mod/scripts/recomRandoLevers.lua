LUAGUI_NAME = "recomRandoLevers"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories Randomizer: applies the lever seed (levers.json)"

local khrecom = require("khrecom_lua_library")
local settings = require("recom_settings")

local FRAMES_BETWEEN_EXE_WRITES = 120
local SORA_STORY = "sora"
local FLOORS_2_TO_6 = "floors_2_to_6"
local FLOORS_7_TO_10 = "floors_7_to_10"
local FLOORS_2_TO_6_SLOT_COUNT = 5
local FLOORS_7_TO_10_SLOT_COUNT = 4
local FIRST_WORLD = 1
local LAST_WORLD = 13
local BOSS_REWARD_RECORD_COUNT = 27
local LEVEL_UP_SLOT_COUNT = 12
local DAYS_NOT_WATCHED = 0
local DAYS_WATCHED = 1

local levers = nil
local frame_count = 0

local function is_whole_number(value, lowest, highest)
    if type(value) ~= "number" then
        return false
    end
    if math.floor(value) ~= value then
        return false
    end
    return value >= lowest and value <= highest
end

local function report(message)
    ConsolePrint("Levers: " .. message)
end

local function check_world_list(world_ids, slot_count)
    if type(world_ids) ~= "table" or #world_ids ~= slot_count then
        return false
    end
    for _, world_id in ipairs(world_ids) do
        if not is_whole_number(world_id, FIRST_WORLD, LAST_WORLD) then
            return false
        end
    end
    return true
end

local function write_world_select()
    local world_select = levers.world_select
    if world_select == nil then
        return
    end
    if not check_world_list(world_select.floors_2_to_6, FLOORS_2_TO_6_SLOT_COUNT) then
        return
    end
    if not check_world_list(world_select.floors_7_to_10, FLOORS_7_TO_10_SLOT_COUNT) then
        return
    end
    for slot, world_id in ipairs(world_select.floors_2_to_6) do
        khrecom.set_world_select_card(FLOORS_2_TO_6, SORA_STORY, slot, world_id)
    end
    for slot, world_id in ipairs(world_select.floors_7_to_10) do
        khrecom.set_world_select_card(FLOORS_7_TO_10, SORA_STORY, slot, world_id)
    end
end

local function write_boss_rewards()
    local boss_rewards = levers.boss_rewards
    if type(boss_rewards) ~= "table" then
        return
    end
    for _, reward in ipairs(boss_rewards) do
        local record_ok = is_whole_number(reward.record, 1, BOSS_REWARD_RECORD_COUNT)
        local card_ok = is_whole_number(reward.card, 1, 0xFF)
        local value_ok = is_whole_number(reward.value, 0, 9)
        if record_ok and card_ok and value_ok then
            khrecom.set_boss_reward(reward.record, reward.card, reward.value)
        end
    end
end

local function write_level_up_sleights()
    local level_up_sleights = levers.level_up_sleights
    if type(level_up_sleights) ~= "table" then
        return
    end
    for _, entry in ipairs(level_up_sleights) do
        local slot_ok = is_whole_number(entry.slot, 1, LEVEL_UP_SLOT_COUNT)
        local level_ok = is_whole_number(entry.level, 1, 100)
        local sleight_ok = is_whole_number(entry.sleight, 1, 0xFF)
        if slot_ok and level_ok and sleight_ok then
            khrecom.set_level_up_sleight(entry.slot, entry.level, entry.sleight)
        end
    end
end

local function write_exe_tables()
    write_world_select()
    write_boss_rewards()
    write_level_up_sleights()
end

local function record_enemy_levers()
    if levers.enemy_hp_multiplier ~= nil then
        khrecom.set_enemy_hp_multiplier(levers.enemy_hp_multiplier)
    end
    if levers.enemy_attack_multiplier ~= nil then
        khrecom.set_enemy_attack_multiplier(levers.enemy_attack_multiplier)
    end
    if levers.enemy_exp_multiplier ~= nil then
        khrecom.set_enemy_exp_multiplier(levers.enemy_exp_multiplier)
    end
    if type(levers.enemy_decks) == "table" then
        for _, deck in ipairs(levers.enemy_decks) do
            khrecom.set_enemy_deck(deck.kind, deck.counts)
        end
    end
end

local function record_powers()
    if type(levers.card_powers) == "table" then
        for _, entry in ipairs(levers.card_powers) do
            for hit, power in ipairs(entry.powers) do
                khrecom.set_card_power(entry.card, hit, power)
            end
        end
    end
    if type(levers.sleight_powers) == "table" then
        for _, entry in ipairs(levers.sleight_powers) do
            for hit, power in ipairs(entry.powers) do
                khrecom.set_sleight_power(entry.sleight, hit, power)
            end
        end
    end
end

local function record_card_levers()
    if type(levers.card_cp) == "table" then
        for _, entry in ipairs(levers.card_cp) do
            khrecom.set_card_cp(entry.card, entry.cp)
        end
    end
    if type(levers.moogle_fallback_cards) == "table" then
        for _, entry in ipairs(levers.moogle_fallback_cards) do
            khrecom.set_moogle_fallback_card(entry.category, entry.card)
        end
    end
end

local function record_drop_levers()
    if levers.chest_card_value_weights ~= nil then
        khrecom.set_chest_card_value_weights(levers.chest_card_value_weights)
    end
    if levers.object_card_chance ~= nil then
        khrecom.set_object_card_chance(levers.object_card_chance)
    end
    if levers.object_card_room_cap ~= nil then
        khrecom.set_object_card_room_cap(levers.object_card_room_cap)
    end
    if levers.drops_ignore_unlocks == true then
        khrecom.set_drops_ignore_unlocks(true)
    end
    if type(levers.world_drops) == "table" then
        for _, entry in ipairs(levers.world_drops) do
            local drops = {}
            drops.chest_cards = entry.chest_cards
            drops.object_cards = entry.object_cards
            drops.map_card_value_weights = entry.map_card_value_weights
            khrecom.set_world_drops(entry.world, drops)
        end
    end
end

local function record_card_odds()
    if type(levers.card_odds) ~= "table" then
        return
    end
    for _, entry in ipairs(levers.card_odds) do
        local odds = {}
        odds.chest_cards = entry.chest_cards
        odds.object_cards = entry.object_cards
        odds.map_cards = entry.map_cards
        odds.random_joker_rate = entry.random_joker_rate
        odds.key_to_rewards_rate = entry.key_to_rewards_rate
        khrecom.set_world_card_odds(entry.world, odds)
    end
end

local function record_heartless_levers()
    if levers.heartless_first_drop == true then
        khrecom.set_heartless_first_drop_guaranteed(true)
    end
    if levers.heartless_card_value_weights ~= nil then
        khrecom.set_heartless_card_value_weights(levers.heartless_card_value_weights)
    end
    if type(levers.heartless_rewards) == "table" then
        for _, entry in ipairs(levers.heartless_rewards) do
            khrecom.set_heartless_reward(entry.heartless, entry.card)
        end
    end
end

local function get_chest_reward(entry)
    local reward = {}
    reward.card = entry.card
    reward.sleight = entry.sleight
    return reward
end

local function record_chest_levers()
    if type(levers.room_of_rewards) == "table" then
        for _, entry in ipairs(levers.room_of_rewards) do
            khrecom.set_room_of_rewards_reward(entry.world, entry.chest, get_chest_reward(entry))
        end
    end
    if type(levers.bounties) == "table" then
        for _, entry in ipairs(levers.bounties) do
            khrecom.set_bounty_reward(entry.world, entry.chest, get_chest_reward(entry))
        end
    end
end

local function record_enemy_swaps()
    if type(levers.enemy_swaps) ~= "table" then
        return
    end
    for _, entry in ipairs(levers.enemy_swaps) do
        khrecom.set_world_enemy_swaps(entry.world, entry.swaps)
    end
end

local function record_floor_layout(layout)
    khrecom.set_floor_size(layout.floor, layout.width, layout.depth)
    for _, room in ipairs(layout.rooms) do
        khrecom.set_floor_room(layout.floor, room.id, {x = room.x, y = room.y})
        for door_number, door in ipairs(room.doors) do
            khrecom.set_floor_door(layout.floor, room.id, door_number, door)
        end
    end
end

local function record_floor_levers()
    if type(levers.world_order) == "table" then
        khrecom.set_world_order(levers.world_order)
    end
    if type(levers.floor_layout_order) == "table" then
        khrecom.set_floor_layout_order(levers.floor_layout_order)
    end
    if type(levers.floor_layouts) == "table" then
        for _, layout in ipairs(levers.floor_layouts) do
            record_floor_layout(layout)
        end
    end
end

local function record_event_cards()
    if type(levers.event_cards) ~= "table" then
        return
    end
    for _, entry in ipairs(levers.event_cards) do
        khrecom.set_event_card_reward(entry.world, entry.room, entry.original, entry.card, entry.value)
    end
end

local function record_moogle_levers()
    if levers.moogle_any_card == true then
        khrecom.set_moogle_any_card(true)
    end
    if type(levers.moogle_value_weights) == "table" then
        for _, entry in ipairs(levers.moogle_value_weights) do
            khrecom.set_moogle_value_weights(entry.tier, entry.weights)
        end
    end
    if type(levers.moogle_pools) == "table" then
        for _, entry in ipairs(levers.moogle_pools) do
            khrecom.set_moogle_pool(entry.category, entry.cards)
        end
    end
end

local function record_boss_fights()
    if type(levers.boss_fights) ~= "table" then
        return
    end
    for _, entry in ipairs(levers.boss_fights) do
        khrecom.set_boss_fight(entry.world, entry.arena, entry.kind, entry.variant, entry.position)
    end
end

local function record_enemy_kind_stats()
    if type(levers.enemy_kind_stats) ~= "table" then
        return
    end
    for _, entry in ipairs(levers.enemy_kind_stats) do
        local multipliers = {}
        multipliers.hp = entry.hp
        multipliers.attack = entry.attack
        multipliers.exp = entry.exp
        khrecom.set_enemy_kind_multipliers(entry.kind, multipliers)
    end
end

local function record_starting_deck()
    if type(levers.starting_deck) == "table" then
        khrecom.set_starting_deck(levers.starting_deck)
    end
end

local function record_sleight_levers()
    if type(levers.card_sleights) == "table" then
        for _, entry in ipairs(levers.card_sleights) do
            khrecom.set_card_sleight(entry.card, entry.number, entry.sleight)
        end
    end
    if type(levers.event_sleights) == "table" then
        for _, entry in ipairs(levers.event_sleights) do
            khrecom.set_event_sleight_reward(entry.world, entry.room, entry.original, entry.sleight)
        end
    end
end

local function record_levers()
    khrecom.set_bounties_ignore_clear(true)
    record_floor_levers()
    if levers.story_doors_key_only == true then
        khrecom.set_story_doors_key_only()
    end
    record_enemy_levers()
    record_enemy_swaps()
    record_boss_fights()
    record_enemy_kind_stats()
    record_starting_deck()
    record_moogle_levers()
    record_event_cards()
    record_card_levers()
    record_powers()
    record_drop_levers()
    record_card_odds()
    record_heartless_levers()
    record_chest_levers()
    record_sleight_levers()
end

local function keep_days_watched()
    if khrecom.get_watched_days() == DAYS_NOT_WATCHED then
        khrecom.set_watched_days(DAYS_WATCHED)
    end
end

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        require("VersionCheck")
    else
        ConsolePrint("RE:CoM not detected, not running script")
        return
    end
    levers = settings.get_levers()
    if levers == nil then
        report("no levers.json found, nothing to change")
        return
    end
    record_levers()
    report("seed " .. tostring(levers.seed) .. " loaded")
end

function _OnFrame()
    if not canExecute or levers == nil then
        return
    end
    if frame_count % FRAMES_BETWEEN_EXE_WRITES == 0 then
        write_exe_tables()
    end
    keep_days_watched()
    khrecom.update_data_tables()
    frame_count = frame_count + 1
end
