local seed_vars = require("recom_seed_vars")

local FLOOR_COUNT = 13
local MAX_CARD_SETS = 20
local VANILLA_FLOOR_WORLDS = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
local DEFAULT_CARD_SET = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}
local DEFAULT_ATTACK_POWER = 10
local DEFAULT_EXP_MULTIPLIER = 1

local function get_setting(name)
    local settings = seed_vars["settings"]
    if settings == nil then
        return nil
    end
    return settings[name]
end

local function get_floor_worlds()
    local floor_worlds = get_setting("floor_worlds")
    if type(floor_worlds) ~= "table" or #floor_worlds ~= FLOOR_COUNT then
        return VANILLA_FLOOR_WORLDS
    end
    return floor_worlds
end

local function get_card_sets()
    local card_sets = get_setting("card_sets")
    local usable_sets = {}
    if type(card_sets) == "table" then
        for _, card_set in ipairs(card_sets) do
            if type(card_set) == "table" and #card_set > 0 and #usable_sets < MAX_CARD_SETS then
                usable_sets[#usable_sets + 1] = card_set
            end
        end
    end
    if #usable_sets == 0 then
        usable_sets[1] = DEFAULT_CARD_SET
    end
    return usable_sets
end

local function get_attack_power()
    local attack_power = get_setting("attack_power")
    if type(attack_power) ~= "number" then
        return DEFAULT_ATTACK_POWER
    end
    return attack_power
end

local function get_exp_multiplier()
    local exp_multiplier = get_setting("exp_multiplier")
    if type(exp_multiplier) ~= "number" or exp_multiplier <= 0 then
        return DEFAULT_EXP_MULTIPLIER
    end
    return exp_multiplier
end

local function has_seed_settings()
    return seed_vars["settings"] ~= nil
end

local function get_levers()
    local levers = seed_vars["levers"]
    if type(levers) ~= "table" then
        return nil
    end
    return levers
end

local function has_lever(name)
    local levers = get_levers()
    if levers == nil then
        return false
    end
    return levers[name] ~= nil
end

return {
    FLOOR_COUNT = FLOOR_COUNT,
    get_floor_worlds = get_floor_worlds,
    get_card_sets = get_card_sets,
    get_attack_power = get_attack_power,
    get_exp_multiplier = get_exp_multiplier,
    has_seed_settings = has_seed_settings,
    get_levers = get_levers,
    has_lever = has_lever
}
