local Mod = Furtherance

local prefix = "scripts.furtherance.misc_items."

--#region Collectibles

local collectibles = {
	"alternate_reality",
	"beginners_luck",
	"blood_cyst",
	"book_of_ambit",
	"book_of_books",
	"book_of_swiftness",
	"brunch",
	"butterfly",
	"cardiomyopathy",
	"coffee_break",
	"cosmic_omnibus",
	"crab_legs",
	"d9",
	"box_of_belongings",
	"epitaph",
	"flux",
	"iron",
	"leaking_tank",
	"little_raincoat",
	"neass",
	"old_camera",
	"lil_poofer",
	"pharaoh_cat",
	"polaris",
	"quarantine",
	"rotten_apple",
	"servitude",
	"sunscreen",
	"tech_ix",
	"technology-1",
	"unstable_core",
	"wine_bottle",
	"zzzzoptionszzzz",
}

Mod.LoopInclude(collectibles, prefix .. "collectibles")

--#endregion

--#region Isaac's Keyboard

local keyboard = {
	"key_alt",
	"key_backspace",
	"key_c",
	"key_caps",
	"key_e",
	"key_enter",
	"key_esc",
	"key_f4",
	"key_q",
	"key_shift",
	"key_spacebar",
	"key_tab",
	"key_tilde",
}

Mod.LoopInclude(keyboard, prefix .. "collectibles.isaacs_keyboard")

--#endregion

--#region Astrological Signs

local astrological = {
	"ceres",
	"chiron",
	"ophiuchus",
	"pallas",
	"juno",
	"vesta"
}

Mod.LoopInclude(astrological, prefix .. "collectibles.astrological_signs")

--#endregion

--#region Trinkets

local trinkets = {
	"bi-84",
	"cringe",
	"escape_plan",
	"glitched_penny",
	"grass",
	"hammerhead_worm",
	"nil_num",
	"rebound_worm"
}

Mod.LoopInclude(trinkets, prefix .. "trinkets")

--#endregion

--#region Pickups

local pickups = {
	"ace_of_shields",
	"charged_bomb",
	"charity",
	"faith",
	"golden_card",
	"heartache",
	"hope",
	"key_card",
	"trap_card",
	"two_of_shields",
	"unlucky_penny",
	"rock_hearts"
}

Mod.LoopInclude(pickups, prefix .. "pickups")

--#endregion
