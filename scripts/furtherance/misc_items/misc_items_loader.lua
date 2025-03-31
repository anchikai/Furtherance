local Mod = Furtherance

---@param tab table
---@param path string
local function loopInclude(tab, path)
	path = "scripts.furtherance.misc_items." .. path
	for _, fileName in pairs(tab) do
		Mod.Include(path .. "." .. fileName)
	end
end

--#region Collectibles

local collectibles = {
	"alternate_reality",
	"beginners_luck",
	"blood_cyst",
	"book_of_ambit",
	"book_of_books",
	"book_of_swiftness",
	--"brainstorm",
	"brunch",
	"butterfly",
	"cardiomyopathy",
	--"ceres",
	"chiron",
	"cosmic_omnibus",
	"crab_legs",
	"d9",
	"dads_wallet",
	"flux",
	"iron",
	"juno",
	"leaking_tank",
	"little_raincoat",
	"neass",
	"old_camera",
	"ophiuchus",
	"pallas",
	"parasitic_poofer",
	--"pharaoh_cat",
	"polaris",
	"quarantine",
	"rotten_apple",
	"servitude",
	"sunscreen",
	--"tech_ix",
	--"technology-1",
	"unstable_core",
	"wine_bottle",
	"zzzzoptionszzzz"
}

loopInclude(collectibles, "collectibles")

--#endregion

--#region Keyboard

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

loopInclude(keyboard, "collectibles.keyboard")

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
	"slick_worm"
}

loopInclude(trinkets, "trinkets")

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
	"unlucky_penny"
}

loopInclude(pickups, "pickups")

--#endregion
