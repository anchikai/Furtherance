local Mod = Furtherance
local patches = Mod.PatchesLoader

local function furtherancePatch()
	Mod.Insert(Mod.Item.ROTTEN_APPLE.WORMS, Mod.Trinket.REBOUND_WORM.ID)
	Mod.Insert(Mod.Item.ROTTEN_APPLE.WORMS, Mod.Trinket.HAMMERHEAD_WORM.ID)
	Mod.HeartGroups.Soul[Mod.Pickup.MOON_HEART.ID] = true
	Mod.HeartAmount[Mod.Pickup.MOON_HEART.ID] = 2
end

patches:RegisterPatch("Furtherance", furtherancePatch)
