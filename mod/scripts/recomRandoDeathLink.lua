LUAGUI_NAME = "recomRandoDeathLink"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration: DeathLink"

local khrecom = require("khrecom_lua_library")
local settings = require("recom_settings")
local client_files = require("recom_client_files")

local SECONDS_BETWEEN_RECEIVED_DEATHS = 3
local HP_WHEN_UNKNOWN = 100

local last_death_time = 0
local last_hp = HP_WHEN_UNKNOWN

local function get_current_hp()
    if khrecom.get_time_played() <= 0 then
        return HP_WHEN_UNKNOWN
    end
    local hp = khrecom.get_sora_hp()
    if hp == nil then
        return HP_WHEN_UNKNOWN
    end
    return hp
end

local function receive_death()
    local death_time = client_files.read_client_file_number("dlreceive")
    if death_time == nil then
        return
    end
    if death_time >= last_death_time + SECONDS_BETWEEN_RECEIVED_DEATHS then
        khrecom.ko_sora()
        last_death_time = death_time
    end
end

local function send_death()
    local death_date = os.date("!%Y%m%d%H%M%S")
    client_files.create_client_file_if_missing("dlsend" .. death_date)
end

local function update()
    receive_death()
    local current_hp = get_current_hp()
    if current_hp == 0 and last_hp > 0 then
        ConsolePrint("Sending death")
        send_death()
    end
    last_hp = current_hp
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
    update()
end
