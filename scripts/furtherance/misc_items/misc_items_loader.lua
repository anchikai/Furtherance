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
	"d9"
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

}

loopInclude(trinkets, "trinkets")

--#endregion

--#region Pickups

local pickups = {

}

loopInclude(pickups, "pickups")

--#endregion
