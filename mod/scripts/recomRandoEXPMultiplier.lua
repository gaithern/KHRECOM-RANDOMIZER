LUAGUI_NAME = "recomRandoEXPMultiplier"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration: EXP multiplier"

local khrecom = require("khrecom_lua_library")
local settings = require("recom_settings")

local FRAMES_BETWEEN_UPDATES = 120
local VANILLA_EXP_GEM_DIVISORS = {1400, 99, 60, 30, 10, 5, 1}

local frame_count = 0

local function apply_exp_multiplier()
    local exp_multiplier = settings.get_exp_multiplier()
    for gem_number, vanilla_divisor in ipairs(VANILLA_EXP_GEM_DIVISORS) do
        local new_divisor = math.floor(vanilla_divisor / exp_multiplier)
        if new_divisor < 1 then
            new_divisor = 1
        end
        khrecom.set_exp_gem_divisor(gem_number, new_divisor)
    end
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
        apply_exp_multiplier()
    end
    frame_count = frame_count + 1
end
