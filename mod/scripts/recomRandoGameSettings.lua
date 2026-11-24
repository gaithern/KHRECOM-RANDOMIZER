LUAGUI_NAME = "recomRandoGameSettings"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration: attack power, level-up sleights and fixed flags"

local khrecom = require("khrecom_lua_library")
local settings = require("recom_settings")

local FRAMES_BETWEEN_UPDATES = 120
local DEFAULT_ATTACK_POWER = 10
local BLIZZARD_JOURNAL_INDEX = 25
local FRIEND_FLAG_VALUE = 0xFF

local frame_count = 0

local function apply_attack_power()
    local attack_power = settings.get_attack_power()
    if attack_power == DEFAULT_ATTACK_POWER then
        return
    end
    if khrecom.get_attack_power() == DEFAULT_ATTACK_POWER then
        khrecom.set_attack_power(attack_power)
    end
end

local function update()
    khrecom.set_journal_card_found(BLIZZARD_JOURNAL_INDEX, 1)
    if not settings.has_lever("level_up_sleights") then
        khrecom.disable_level_up_sleights()
    end
    apply_attack_power()
    khrecom.set_friend_flag(FRIEND_FLAG_VALUE)
end

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        require("VersionCheck")
        if not settings.has_seed_settings() then
            canExecute = false
            ConsolePrint("No Archipelago seed settings, not running " .. LUAGUI_NAME)
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
