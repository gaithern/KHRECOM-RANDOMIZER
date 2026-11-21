LUAGUI_NAME = "recomRandoEnableDaysLocations"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration: marks 358/2 Days as watched"

local khrecom = require("khrecom_lua_library")

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
    if khrecom.get_watched_days() == 0 then
        khrecom.set_watched_days(1)
    end
end
