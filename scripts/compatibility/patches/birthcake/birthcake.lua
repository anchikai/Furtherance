local Mod = Furtherance
local loader = Mod.PatchesLoader

local FR_BIRTHCAKE = {}

Furtherance.BIRTHCAKE_SUPPORT = FR_BIRTHCAKE

--[[ local birthcakeFiles = {
	"leah",
	"peter",
	"miriam"
}

Mod.LoopInclude(birthcakeFiles, "scripts.compatibility.patches.birthcake") ]]

FR_BIRTHCAKE.BirthcakeDescriptions = {
	[Mod.PlayerType.LEAH] = {
		Name = "Leah's",
		PickupQuote = "???",
		AccurateBlurb = "Accurate?",
		EIDDesc = "???",
		SpriteName = "leah"
	},
	[Mod.PlayerType.LEAH_B] = {
		Name = "Tainted Leah's",
		Title = "The Unloved's",
		PickupQuote = "???",
		AccurateBlurb = "Accurate?",
		EIDDesc = "???",
		SpriteName = "leah_b"
	},
	[Mod.PlayerType.PETER] = {
		Name = "Peter's",
		PickupQuote = "???",
		AccurateBlurb = "Accurate?",
		EIDDesc = "???",
		SpriteName = "peter"
	},
	[Mod.PlayerType.PETER_B] = {
		Name = "Tainted Peter's",
		Title = "The Martyr's",
		PickupQuote = "???",
		AccurateBlurb = "Accurate?",
		EIDDesc = "???",
		SpriteName = "peter_b"
	},
	[Mod.PlayerType.MIRIAM] = {
		Name = "Miriam's",
		PickupQuote = "???",
		AccurateBlurb = "Accurate?",
		EIDDesc = "???",
		SpriteName = "miriam"
	},
	[Mod.PlayerType.MIRIAM_B] = {
		Name = "Tainted Miriam's",
		Title = "The Condemned's",
		PickupQuote = "???",
		AccurateBlurb = "Accurate?",
		EIDDesc = "???",
		SpriteName = "miriam_b"
	},
}
local birthcakePath = "gfx/items/trinkets/birthcake_"

local function birthcakePatch()
	local api = BirthcakeRebaked.API
	for playerType, info in pairs(FR_BIRTHCAKE.BirthcakeDescriptions) do
		if info.Title then
			api:AddTaintedBirthcakePickupText(playerType, info.PickupQuote, EntityConfig.GetPlayer(playerType):GetTaintedCounterpart(), info.Name, info.Title)
		else
			api:AddBirthcakePickupText(playerType, info.PickupQuote, info.Name)
		end
		api:AddAccurateBlurbcake(playerType, info.AccurateBlurb)
		api:AddBirthcakeSprite(playerType, {SpritePath = birthcakePath .. info.SpriteName .. ".png"})
		api:AddEIDDescription(playerType, info.EIDDesc)
	end
end

loader:RegisterPatch("BirthcakeRebaked", birthcakePatch)