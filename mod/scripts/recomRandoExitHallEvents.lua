LUAGUI_NAME = "recomRandoExitHallEvents"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration: Exit Hall story fights follow story progress"

local khrecom = require("khrecom_lua_library")

local FRAMES_BETWEEN_UPDATES = 120
local NEW_GAME_TIME_PLAYED = 5
local LARXENE_II_JOURNAL_INDEX = 107
local EXIT_HALL_FIX_ROOM = 0x17
local EXIT_HALL_FIX_WORLD_VALUE = 0x0
local EXIT_HALL_FIX_PROGRESS = 6

local story_fights = {
    {name = "1F Exit Hall: Axel I", story_progress = 0, first_byte = 3, event_low = 0xD2, event_high = 0x07},
    {name = "6F Exit Hall: Larxene I", story_progress = 1, first_byte = 23, event_low = 0xDC, event_high = 0x07},
    {name = "7F Exit Hall: Riku I", story_progress = 2, first_byte = 27, event_low = 0xDE, event_high = 0x07},
    {name = "8F Exit Hall: Riku II", story_progress = 3, first_byte = 31, event_low = 0xE0, event_high = 0x07},
    {name = "10F Exit Hall: Vexen I", story_progress = 4, first_byte = 39, event_low = 0xE4, event_high = 0x07},
    {name = "11F Exit Hall: Riku III", story_progress = 5, first_byte = 43, event_low = 0xE6, event_high = 0x07},
    {name = "Exit Hall fix", story_progress = 6, first_byte = 45, event_low = 0xE7, event_high = 0x07},
    {name = "12F Exit Hall: Riku IV", story_progress = 7, first_byte = 47, event_low = 0xE8, event_high = 0x07}
}

local larxene_ii_fight = {name = "12F Exit Hall: Larxene II", first_byte = 47, event_low = 0xE1, event_high = 0x00}

local frame_count = 0

local function get_default_exit_hall_events()
    local events = {}
    for floor_number = 1, 24 do
        events[(floor_number * 2) - 1] = floor_number
        events[floor_number * 2] = 0
    end
    return events
end

local function count_new_world_journal_entries()
    local world_journal_entries = khrecom.get_world_journal_entries()
    local story_progress = khrecom.get_story_progress()
    for world_number, journal_byte in ipairs(world_journal_entries) do
        if journal_byte > 0 then
            world_journal_entries[world_number] = 0
            story_progress = story_progress + 1
        end
    end
    khrecom.set_world_journal_entries(world_journal_entries)
    khrecom.set_story_progress(story_progress)
    return story_progress
end

local function place_fight(events, fight)
    events[fight.first_byte] = fight.event_low
    events[fight.first_byte + 1] = fight.event_high
end

local function get_exit_hall_events(story_progress)
    local events = get_default_exit_hall_events()
    for _, fight in ipairs(story_fights) do
        if fight.story_progress == story_progress then
            place_fight(events, fight)
        end
    end
    local beat_larxene_ii = khrecom.get_journal_cards_found()[LARXENE_II_JOURNAL_INDEX] > 0
    if story_progress > 7 and not beat_larxene_ii then
        place_fight(events, larxene_ii_fight)
    end
    return events
end

local function finish_exit_hall_fix(story_progress)
    if story_progress ~= EXIT_HALL_FIX_PROGRESS then
        return
    end
    if khrecom.get_current_room() ~= EXIT_HALL_FIX_ROOM then
        return
    end
    if khrecom.get_journal_world_value() ~= EXIT_HALL_FIX_WORLD_VALUE then
        return
    end
    khrecom.set_story_progress(story_progress + 1)
end

local function update()
    if khrecom.get_time_played() <= NEW_GAME_TIME_PLAYED then
        return
    end
    local story_progress = count_new_world_journal_entries()
    local events = get_exit_hall_events(story_progress)
    finish_exit_hall_fix(story_progress)
    khrecom.set_exit_hall_events(events)
end

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        require("VersionCheck")
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
