local JOURNAL_CARD_LOCATION_BASE = 2690000
local ROOM_LOCATION_BASE = 2691000
local HEARTLESS_FIRST_DEFEAT_LOCATION_BASE = 2691200
local HEARTLESS_SECOND_DEFEAT_LOCATION_BASE = 2691300
local HEARTLESS_THIRD_DEFEAT_LOCATION_BASE = 2691400
local TRINITY_LIMIT_LOCATION = 2692009
local PIGLET_LOCATION = 2692043
local FINAL_MARLUXIA_LOCATION = 2699999

local journal_card_checks = {
    {name = "Fire", journal_index = 24, location_ids = {2692010, 2692017}},
    {name = "Blizzard", journal_index = 25, location_ids = {2692011, 2692018}},
    {name = "Thunder", journal_index = 26, location_ids = {2692012, 2692019}},
    {name = "Cure", journal_index = 27, location_ids = {2692013, 2692020}},
    {name = "Gravity", journal_index = 28, location_ids = {2692014, 2692021}},
    {name = "Stop", journal_index = 29, location_ids = {2692015, 2692022}},
    {name = "Aero", journal_index = 30, location_ids = {2692016, 2692023}},
    {name = "Simba", journal_index = 31, location_ids = {2692049, 2692050}},
    {name = "Genie", journal_index = 32, location_ids = {2692058, 2692059}},
    {name = "Bambi", journal_index = 33, location_ids = {2692053, 2692054}},
    {name = "Dumbo", journal_index = 34, location_ids = {2692051, 2692052}},
    {name = "Tinker Bell", journal_index = 35, location_ids = {2692060, 2692061}},
    {name = "Mushu", journal_index = 36, location_ids = {2692056, 2692057}},
    {name = "Cloud", journal_index = 37, location_ids = {2692062, 2692063}}
}

local reward_bounty_checks = {
    {name = "Warp", reward_index = 2, minimum = 1, location_id = 2692041},
    {name = "Synchro", reward_index = 4, minimum = 1, location_id = 2692045},
    {name = "Aqua Splash", reward_index = 5, minimum = 1, location_id = 2692034},
    {name = "Bind", reward_index = 6, minimum = 1, location_id = 2692042},
    {name = "Quake", reward_index = 7, minimum = 1, location_id = 2692039},
    {name = "Thunder Raid", reward_index = 8, minimum = 1, location_id = 2692026},
    {name = "Stardust Blitz", reward_index = 11, minimum = 1, location_id = 2692067},
    {name = "Blizzard Raid", reward_index = 36, minimum = 1, location_id = 2692025},
    {name = "Fire Raid", reward_index = 38, minimum = 1, location_id = 2692024},
    {name = "Gifted Miracle", reward_index = 39, minimum = 1, location_id = 2692046},
    {name = "Shock Impact", reward_index = 40, minimum = 1, location_id = 2692037},
    {name = "Homing Blizzara", reward_index = 40, minimum = 2, location_id = 2692033},
    {name = "Teleport", reward_index = 41, minimum = 1, location_id = 2692047},
    {name = "Reflect Raid", reward_index = 42, minimum = 1, location_id = 2692027},
    {name = "Warpinator", reward_index = 44, minimum = 1, location_id = 2692040},
    {name = "Judgement", reward_index = 45, minimum = 1, location_id = 2692028},
    {name = "Raging Storm", reward_index = 46, minimum = 1, location_id = 2692030}
}

local friend_card_checks = {
    {name = "Donald", friend_index = 1, location_ids = {2692065, 2692066}},
    {name = "Goofy", friend_index = 2, location_ids = {2692068, 2692069, 2692070, 2692071}},
    {name = "Aladdin", friend_index = 3, location_ids = {2692072, 2692073}},
    {name = "Ariel", friend_index = 4, location_ids = {2692076, 2692077}},
    {name = "Jack", friend_index = 5, location_ids = {2692044, 2692074, 2692075}},
    {name = "Peter Pan", friend_index = 6, location_ids = {2692078, 2692079}},
    {name = "Beast", friend_index = 7, location_ids = {2692080, 2692081}},
    {name = "Pluto", friend_index = 8, location_ids = {2692082, 2692083}}
}

local minigame_checks = {
    {name = "Firaga Burst", minigame_index = 1, location_id = 2692029},
    {name = "Idyll Romp", minigame_index = 4, location_id = 2692055},
    {name = "Cross-Slash +", minigame_index = 5, location_id = 2692064}
}

local level_up_checks = {
    {name = "Sliding Dash", level = 2, location_id = 2692001},
    {name = "Stun Impact", level = 7, location_id = 2692003},
    {name = "Strike Raid", level = 12, location_id = 2692005},
    {name = "Blitz", level = 17, location_id = 2692002},
    {name = "Zantetsuken", level = 22, location_id = 2692004},
    {name = "Sonic Blade", level = 27, location_id = 2692006},
    {name = "Lethal Frame", level = 32, location_id = 2692036},
    {name = "Tornado", level = 37, location_id = 2692038},
    {name = "Ars Arcanum", level = 42, location_id = 2692007},
    {name = "Holy", level = 47, location_id = 2692048},
    {name = "Ragnarok", level = 52, location_id = 2692008},
    {name = "Mega Flare", level = 57, location_id = 2692031}
}

local story_progress_checks = {
    {name = "Riku II Magnet Spiral", minimum_progress = 4, location_id = 2692035},
    {name = "Vexen I Freeze", minimum_progress = 5, location_id = 2692032}
}

return {
    JOURNAL_CARD_LOCATION_BASE = JOURNAL_CARD_LOCATION_BASE,
    ROOM_LOCATION_BASE = ROOM_LOCATION_BASE,
    HEARTLESS_FIRST_DEFEAT_LOCATION_BASE = HEARTLESS_FIRST_DEFEAT_LOCATION_BASE,
    HEARTLESS_SECOND_DEFEAT_LOCATION_BASE = HEARTLESS_SECOND_DEFEAT_LOCATION_BASE,
    HEARTLESS_THIRD_DEFEAT_LOCATION_BASE = HEARTLESS_THIRD_DEFEAT_LOCATION_BASE,
    TRINITY_LIMIT_LOCATION = TRINITY_LIMIT_LOCATION,
    PIGLET_LOCATION = PIGLET_LOCATION,
    FINAL_MARLUXIA_LOCATION = FINAL_MARLUXIA_LOCATION,
    journal_card_checks = journal_card_checks,
    reward_bounty_checks = reward_bounty_checks,
    friend_card_checks = friend_card_checks,
    minigame_checks = minigame_checks,
    level_up_checks = level_up_checks,
    story_progress_checks = story_progress_checks
}
