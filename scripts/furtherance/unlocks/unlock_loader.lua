local Mod = Furtherance

local prefix = "scripts.furtherance.unlocks.unlocks_"

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

Mod.LoopInclude(leah, prefix .. "leah")

--#endregion

--#region Tainted Leah

local leah_b = {
	"soul_of_leah",
	"cold_hearted",
	"leahs_heart",
	"love_teller",
	"essence_of_hate",
	"reverse_hope",
	"moon_hearts",
}

Mod.LoopInclude(leah_b, prefix .. "leah_b")

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

Mod.LoopInclude(peter, prefix .. "peter")

--#endregion

--#region Tainted Peter

local peter_b = {
	"essence_of_death",
	"dungeon_key",
	"leviathans_tendril",
	"reverse_faith",
	"soul_of_peter",
	"trepanation",
}

Mod.LoopInclude(peter_b, prefix .. "peter_b")

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

Mod.LoopInclude(miriam, prefix .. "miriam")

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
}

Mod.LoopInclude(miriam_b, prefix .. "miriam_b")

--#endregion

Mod.Include("scripts.furtherance.unlocks.unlock_table")
Mod.Include("scripts.furtherance.unlocks.unlock_tracker_marks")
