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
		PickupQuote = "Move love",
		AccurateBlurb = "Hearts might be worth double for Heart Renovator",
		EIDDesc = "Picking up {{Heart}} Red Hearts at full health have a 50% chance to grant double its amount into {{Collectible" .. Mod.Item.HEART_RENOVATOR.ID .. "}} Heart Renovator's counter",
		SpriteName = "leah"
	},
	[Mod.PlayerType.LEAH_B] = {
		Name = "Tainted Leah's",
		Title = "The Unloved's",
		PickupQuote = "Rip their hearts out",
		AccurateBlurb = "Special hearts drop from damaged enemies more often",
		EIDDesc = "Doubles the chance of special heart pickups spawning from damaged enemies",
		SpriteName = "leah_b"
	},
	[Mod.PlayerType.PETER] = {
		Name = "Peter's",
		PickupQuote = "Recycled souls",
		AccurateBlurb = "Spared enemies may become active charge",
		EIDDesc = "Souls from spared enemies have a chance to grant charge to {{Collectible" .. Mod.Item.KEYS_TO_THE_KINGDOM.ID .. "}} Keys to the Kingdom",
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