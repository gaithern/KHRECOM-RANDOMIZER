local json = require("json")

local SEED_FILE_NAMES = {"settings", "levers"}

local function get_seed_folder()
    if type(SCRIPT_PATH) ~= "string" then
        return "io_packages/json/"
    end
    return SCRIPT_PATH .. "/io_packages/json/"
end

local function load_seed_file(file_path)
    local file = io.open(file_path, "r")
    if file == nil then
        return nil
    end
    local text = file:read("*a")
    file:close()
    local ok, decoded = pcall(json.decode, text)
    if not ok then
        ConsolePrint("Could not read seed file " .. file_path .. ": " .. tostring(decoded))
        return nil
    end
    return decoded
end

local function load_seed_vars()
    local seed_vars = {}
    local seed_folder = get_seed_folder()
    for _, file_name in ipairs(SEED_FILE_NAMES) do
        seed_vars[file_name] = load_seed_file(seed_folder .. file_name .. ".json")
    end
    if seed_vars["settings"] == nil and seed_vars["levers"] == nil then
        ConsolePrint("No seed found, is a seed mod installed?")
    end
    return seed_vars
end

return load_seed_vars()
