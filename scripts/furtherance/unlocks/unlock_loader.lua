---@param tab table
---@param path string
local function loopInclude(tab, path)
	path = "scripts.furtherance.unlocks.unlocks_" .. path
	for _, fileName in pairs(tab) do
		Furtherance.Include(path .. "." .. fileName)
	end
end

--#region Leah

local leah = {
	"secret_diary",
	"binds_of_devotion",
	"rue",
	"leahs_lock",
	"mandrake",
	"parasol",
	"d16",
	"holy_heart",
	"keratoconus",
	"heart_embedded_coin",
	"heart_renovator",
	"owls_eye",
	"essence_of_love",
	"exsanguination"
}

loopInclude(leah, "leah")

--#endregion

--#region Tainted Leah

local leah_b = {
}

loopInclude(leah_b, "leah_b")

--#endregion

--#region Peter

local peter = {
	"prayer_journal",
	"pallium",
	"severed_ear",
	"chi_ro",
	"book_of_leviticus",
	"altruism",
	"astragali",
	"alabaster_scrap",
	"liberation",
	"molten_gold",
	--keyts
	"itching_powder",
	"essence_of_life",
	"golden_port"
}

loopInclude(peter, "peter")

--#endregion

--#region Tainted Peter

local peter_b = {

}

loopInclude(peter_b, "peter_b")

--#endregion

--#region Miriam

local miriam = {
	"book_of_guidance",
	"apocalypse",
	"kareth",
	"pillar_of_clouds",
	"pillar_of_fire",
	"wormwood_leaf",
	"caduceus_staff",
	"the_dreidel",
	--tambourine (might be reworked to a wave instead of whirlpool)
	"firstborn_son",
	"essence_of_prosperity",
	"essence_of_drought",
	"saline_spray",
	"miriams_well"
	--polydipsia
}

loopInclude(miriam, "miriam")

--#endregion

--#region Tainted Miriam

local miriam_b = {

}

loopInclude(miriam_b, "miriam_b")

--#endregion

--#region Challenges

local challenges = {

}

loopInclude(challenges, "challenges")

--#endregion

--#region Misc

local misc = {

}

loopInclude(misc, "misc")

--#endregion

Furtherance.Include("scripts.furtherance.unlocks.unlock_table")
Furtherance.Include("scripts.furtherance.unlocks.unlock_tracker_marks")
Furtherance.Include("scripts.furtherance.unlocks.unlock_tracker_misc")