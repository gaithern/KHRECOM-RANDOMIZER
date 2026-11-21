LUAGUI_NAME = "recomRandoConnector"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration: items and checks"

local khrecom = require("khrecom_lua_library")
local client_files = require("recom_client_files")
local locations = require("recom_locations")
local settings = require("recom_settings")

local FRAMES_BETWEEN_UPDATES = 120
local NEW_GAME_TIME_PLAYED = 5
local CARD_SET_ITEM_BASE = 2681000
local ENEMY_CARD_ITEM_BASE = 2681200
local SLEIGHT_ITEM_BASE = 2682000
local WORLD_ITEM_BASE = 2683000
local KEY_TO_REWARDS_ITEM_BASE = 2683300
local FRIEND_ITEM_BASE = 2685000
local VICTORY_ITEM = 2680000
local FRIEND_COUNT = 8
local TRAVERSE_TOWN_WORLD_ID = 0x01
local CASTLE_OBLIVION_WORLD_ID = 0x0D
local LARXENE_II_JOURNAL_INDEX = 107
local FINAL_MARLUXIA_ROOM = 0x07D4
local KINGDOM_KEY_CARD_INDEX = 1
local KINGDOM_KEY_CARD_ID = 1
local STARTING_DECK_FLAGS = 17
local STARTING_DECK_WITHOUT_SEED = {1, 2, 3}
local MAP_CARD_SLOTS_FILLED = 220
local MAP_CARD_COUNT_PER_SLOT = 9
local FRIEND_CARD_IDS = {49, 50, 51, 52, 55, 54, 53, 57}
local FRIEND_FOUND_FLAGS = 68
local FRIEND_MISSING_FLAGS = 119

local frame_count = 0
local floor_worlds = settings.get_floor_worlds()
local card_sets = settings.get_card_sets()
local item_index = 0
local battle_card_inventory = {}
local enemy_card_inventory = {}
local sleights_obtained = {}
local unlocked_worlds = {}
local friends_found = {}
local friend_count = 0
local card_sets_received = {}
local key_to_rewards_found = {}
local victory = false

local function get_filled_list(size, value)
    local list = {}
    for index = 1, size do
        list[index] = value
    end
    return list
end

local function reset_state()
    battle_card_inventory = khrecom.get_empty_battle_card_inventory()
    enemy_card_inventory = get_filled_list(PLAYER_DATA_ENEMY_CARDS_SIZE, 0)
    sleights_obtained = get_filled_list(khrecom.get_sleight_count(), 0)
    unlocked_worlds = {}
    friends_found = get_filled_list(FRIEND_COUNT, 0)
    friend_count = 0
    card_sets_received = {}
    key_to_rewards_found = {}
    item_index = 0
    victory = false
end

local function is_castle_oblivion_unlocked()
    if friend_count < FRIEND_COUNT then
        return false
    end
    return khrecom.get_journal_cards_found()[LARXENE_II_JOURNAL_INDEX] > 0
end

local function is_world_unlocked(world_id)
    if world_id == TRAVERSE_TOWN_WORLD_ID then
        return true
    end
    if world_id == CASTLE_OBLIVION_WORLD_ID then
        return is_castle_oblivion_unlocked()
    end
    return unlocked_worlds[world_id] == true
end

local function is_floor_unlocked(floor_number)
    local world_id = floor_worlds[floor_number]
    if world_id == nil then
        return false
    end
    return is_world_unlocked(world_id)
end

local function choose_world_select_choices(floor_number, is_sora_story, vanilla_choices)
    if not is_sora_story then
        return nil
    end
    local world_id = floor_worlds[floor_number]
    if world_id == nil then
        return nil
    end
    local locked = not is_world_unlocked(world_id)
    return {world_id}, locked
end

local function choose_warp_menu_world(floor_number)
    local world_id = floor_worlds[floor_number]
    if world_id == nil then
        return nil
    end
    if not is_world_unlocked(world_id) then
        return nil
    end
    return world_id
end

local function add_card_set(card_index, sets_received_for_card)
    local set_number = ((sets_received_for_card - 1) % #card_sets) + 1
    for _, card_value in ipairs(card_sets[set_number]) do
        khrecom.add_battle_card(battle_card_inventory, card_index, card_value)
    end
end

local function add_starting_battle_cards()
    for _, card_value in ipairs(card_sets[1]) do
        khrecom.add_battle_card(battle_card_inventory, KINGDOM_KEY_CARD_INDEX, card_value)
    end
end

local function write_starting_deck()
    local starting_values = STARTING_DECK_WITHOUT_SEED
    if settings.has_seed_settings() then
        starting_values = card_sets[1]
    end
    local deck_entries = {}
    for _, card_value in ipairs(starting_values) do
        local entry = {}
        entry.card_id = KINGDOM_KEY_CARD_ID
        entry.premium = 0
        if card_value >= 10 then
            entry.premium = 1
        end
        entry.value = card_value % 10
        entry.flags = STARTING_DECK_FLAGS
        deck_entries[#deck_entries + 1] = entry
    end
    khrecom.set_deck(1, khrecom.build_deck_bytes(deck_entries))
end

local function write_full_map_cards()
    local map_cards = {}
    for slot = 1, PLAYER_DATA_MAP_CARDS_SIZE do
        if slot <= MAP_CARD_SLOTS_FILLED then
            map_cards[slot] = MAP_CARD_COUNT_PER_SLOT
        else
            map_cards[slot] = 0
        end
    end
    khrecom.set_map_card_inventory(map_cards)
end

local function write_friend_cards_on_deck_3()
    local deck_bytes = {}
    for friend_number = 1, FRIEND_COUNT do
        local first_byte = ((friend_number - 1) * 4) + 1
        deck_bytes[first_byte] = FRIEND_CARD_IDS[friend_number]
        deck_bytes[first_byte + 1] = 0
        deck_bytes[first_byte + 2] = 1
        if friends_found[friend_number] > 0 then
            deck_bytes[first_byte + 3] = FRIEND_FOUND_FLAGS
        else
            deck_bytes[first_byte + 3] = FRIEND_MISSING_FLAGS
        end
    end
    khrecom.set_deck(3, deck_bytes)
end

local function handle_received_item(item_id)
    if item_id > CARD_SET_ITEM_BASE and item_id < ENEMY_CARD_ITEM_BASE then
        local card_index = item_id - CARD_SET_ITEM_BASE
        if card_sets_received[card_index] == nil then
            card_sets_received[card_index] = 0
        end
        card_sets_received[card_index] = card_sets_received[card_index] + 1
        add_card_set(card_index, card_sets_received[card_index])
    elseif item_id > ENEMY_CARD_ITEM_BASE and item_id < SLEIGHT_ITEM_BASE then
        local enemy_card_index = item_id - ENEMY_CARD_ITEM_BASE
        enemy_card_inventory[enemy_card_index] = enemy_card_inventory[enemy_card_index] + 1
    elseif item_id > SLEIGHT_ITEM_BASE and item_id < WORLD_ITEM_BASE then
        local sleight_index = item_id - SLEIGHT_ITEM_BASE
        sleights_obtained[sleight_index] = 1
    elseif item_id > WORLD_ITEM_BASE and item_id < KEY_TO_REWARDS_ITEM_BASE then
        local world_id = item_id - WORLD_ITEM_BASE
        unlocked_worlds[world_id] = true
    elseif item_id > KEY_TO_REWARDS_ITEM_BASE and item_id < 2684000 then
        local world_id = item_id - KEY_TO_REWARDS_ITEM_BASE
        key_to_rewards_found[#key_to_rewards_found + 1] = world_id
    elseif item_id > FRIEND_ITEM_BASE and item_id < 2686000 then
        local friend_index = item_id - FRIEND_ITEM_BASE
        if friends_found[friend_index] ~= 1 then
            friend_count = friend_count + 1
            friends_found[friend_index] = 1
        end
    elseif item_id == VICTORY_ITEM then
        victory = true
    end
end

local function read_new_items()
    while true do
        local item_file_name = "AP_" .. tostring(item_index) .. ".item"
        if not client_files.client_file_exists(item_file_name) then
            return
        end
        local item_id = client_files.read_client_file_number(item_file_name)
        if item_id ~= nil then
            handle_received_item(item_id)
        end
        item_index = item_index + 1
    end
end

local function get_gold_map_cards(current_floor)
    local gold_map_cards = {0, 0, 0, 0}
    if not is_floor_unlocked(current_floor) then
        return gold_map_cards
    end
    gold_map_cards[1] = 1
    gold_map_cards[2] = 1
    gold_map_cards[3] = 1
    for _, key_world_id in ipairs(key_to_rewards_found) do
        if floor_worlds[current_floor] == key_world_id then
            gold_map_cards[4] = 1
        end
    end
    return gold_map_cards
end

local function receive_items()
    local current_floor = khrecom.get_current_floor()
    write_full_map_cards()

    if item_index == 0 then
        add_starting_battle_cards()
        item_index = 1
    end

    read_new_items()

    khrecom.set_battle_card_inventory(battle_card_inventory)
    khrecom.set_enemy_card_inventory(enemy_card_inventory)
    khrecom.set_sleights_obtained(sleights_obtained)
    khrecom.set_gold_map_cards(get_gold_map_cards(current_floor))
    write_friend_cards_on_deck_3()
end

local function send_journal_card_locations()
    local journal_cards_found = khrecom.get_journal_cards_found()
    for journal_index, found in ipairs(journal_cards_found) do
        if found > 0 then
            client_files.send_location(locations.JOURNAL_CARD_LOCATION_BASE + journal_index)
        end
    end
end

local function send_room_locations()
    local rooms_opened = khrecom.get_rooms_opened()
    for room_slot, opened in ipairs(rooms_opened) do
        if opened > 0 then
            local floor_number = math.floor((room_slot - 1) / 3) + 1
            local room_number = ((room_slot - 1) % 3) + 1
            local world_id = floor_worlds[floor_number]
            client_files.send_location(locations.ROOM_LOCATION_BASE + (world_id * 10) + room_number)
        end
    end
end

local function send_heartless_locations()
    local defeat_counts = khrecom.get_heartless_defeated()
    for heartless_number, defeat_count in ipairs(defeat_counts) do
        if defeat_count >= 1 then
            client_files.send_location(locations.HEARTLESS_FIRST_DEFEAT_LOCATION_BASE + heartless_number)
        end
        if defeat_count >= 2 then
            client_files.send_location(locations.HEARTLESS_SECOND_DEFEAT_LOCATION_BASE + heartless_number)
        end
        if defeat_count >= 3 then
            client_files.send_location(locations.HEARTLESS_THIRD_DEFEAT_LOCATION_BASE + heartless_number)
        end
    end
end

local function send_location_list(location_ids)
    for _, location_id in ipairs(location_ids) do
        client_files.send_location(location_id)
    end
end

local function send_extra_locations()
    local journal_cards_found = khrecom.get_journal_cards_found()
    for _, check in ipairs(locations.journal_card_checks) do
        if journal_cards_found[check.journal_index] > 0 then
            send_location_list(check.location_ids)
        end
    end

    local rewards_bounties = khrecom.get_rewards_bounties()
    for _, check in ipairs(locations.reward_bounty_checks) do
        if rewards_bounties[check.reward_index] >= check.minimum then
            client_files.send_location(check.location_id)
        end
    end

    local friend_cards = khrecom.get_friend_cards()
    for _, check in ipairs(locations.friend_card_checks) do
        if friend_cards[check.friend_index] > 0 then
            send_location_list(check.location_ids)
        end
    end

    local minigames_cleared = khrecom.get_minigames_cleared()
    for _, check in ipairs(locations.minigame_checks) do
        if minigames_cleared[check.minigame_index] > 0 then
            client_files.send_location(check.location_id)
        end
    end

    local soras_level = khrecom.get_soras_level()
    for _, check in ipairs(locations.level_up_checks) do
        if soras_level >= check.level then
            client_files.send_location(check.location_id)
        end
    end

    local story_progress = khrecom.get_story_progress()
    for _, check in ipairs(locations.story_progress_checks) do
        if story_progress >= check.minimum_progress then
            client_files.send_location(check.location_id)
        end
    end

    if is_castle_oblivion_unlocked() then
        client_files.send_location(locations.TRINITY_LIMIT_LOCATION)
    end

    if khrecom.is_piglet_found() then
        client_files.send_location(locations.PIGLET_LOCATION)
    end
end

local function is_final_marluxia_slain()
    if khrecom.get_current_world() ~= CASTLE_OBLIVION_WORLD_ID then
        return false
    end
    return khrecom.get_current_room() == FINAL_MARLUXIA_ROOM
end

local function send_checks()
    if khrecom.get_time_played() <= 0 then
        return
    end
    send_journal_card_locations()
    send_room_locations()
    send_heartless_locations()
    send_extra_locations()
    if is_final_marluxia_slain() then
        client_files.send_location(locations.FINAL_MARLUXIA_LOCATION)
    end
    if victory then
        client_files.create_client_file_if_missing("victory")
    end
end

local function update()
    if khrecom.get_time_played() > NEW_GAME_TIME_PLAYED then
        receive_items()
        send_checks()
    else
        reset_state()
        write_starting_deck()
    end
end

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        require("VersionCheck")
        client_files.get_client_communication_path()
        reset_state()
        if canExecute then
            local installed = khrecom.set_world_select_handler(choose_world_select_choices)
            if not installed then
                ConsolePrint("Could not hook the world select screen, floors will offer their vanilla worlds")
            end
            local warp_installed = khrecom.allow_warp_to_unassigned_floors(choose_warp_menu_world)
            if not warp_installed then
                ConsolePrint("Could not patch the floor warp menu, floors without a world cannot be warped to")
            end
        end
    else
        ConsolePrint("RE:CoM not detected, not running script")
    end
end

function _OnFrame()
    if not canExecute then
        return
    end
    if frame_count % FRAMES_BETWEEN_UPDATES == 0 then
        update()
    end
    frame_count = frame_count + 1
end
