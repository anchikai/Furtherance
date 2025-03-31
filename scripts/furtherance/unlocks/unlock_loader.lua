local Mod = Furtherance

---@param tab table
---@param path string
local function loopInclude(tab, path)
	path = "scripts.furtherance.unlocks.unlocks_" .. path
	for _, fileName in pairs(tab) do
		Mod.Include(path .. "." .. fileName)
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
	"owls_eye",
	"essence_of_love",
	"exsanguination"
}

loopInclude(leah, "leah")

--#endregion

--#region Tainted Leah

local leah_b = {
	"soul_of_leah",
	"cold_hearted",
	"leahs_heart",
	"rotten_love",
	"essence_of_hate",
	"reverse_hope",
	"moon_hearts",
}

loopInclude(leah_b, "leah_b")

--#endregion

--#region Peter

local peter = {
	"alabaster_scrap",
	"altruism",
	"astragali",
	"book_of_leviticus",
	"chi_rho",
	"prayer_journal",
	"essence_of_life",
	"golden_port",
	"itching_powder",
	"liberation",
	"molten_gold",
	"pallium",
	"severed_ear",
}

loopInclude(peter, "peter")

--#endregion

--#region Tainted Peter

local peter_b = {
	"essence_of_death",
	"key_to_the_pit",
	"leviathans_tendril",
	"reverse_faith",
	"soul_of_peter",
	"trepanation",
}

loopInclude(peter_b, "peter_b")

--#endregion

--#region Miriam

local miriam = {
	"apocalypse",
	"book_of_guidance",
	"caduceus_staff",
	"essence_of_deluge",
	"firstborn_son",
	"kareth",
	"miriams_well",
	"pillar_of_clouds",
	"pillar_of_fire",
	"saline_spray",
	"the_dreidel",
	"wormwood_leaf",
}

loopInclude(miriam, "miriam")

--#endregion

--#region Tainted Miriam

local miriam_b = {
	"abyssal_penny",
	"almagest_scrap",
	"essence_of_drought",
	"golden_sack",
	"jar_of_manna",
	"reverse_charity",
	"soul_of_miriam",
	"spiritual_wound",
}

loopInclude(miriam_b, "miriam_b")

--#endregion

Mod.Include("scripts.furtherance.unlocks.unlock_table")
Mod.Include("scripts.furtherance.unlocks.unlock_tracker_marks")
