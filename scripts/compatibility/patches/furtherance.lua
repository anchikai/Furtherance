local Mod = Furtherance
local patches = Mod.PatchesLoader

local function furtherancePatch()
	Mod.Insert(Mod.Item.ROTTEN_APPLE.Worms, Mod.Trinket.REBOUND_WORM.ID)
	Mod.Insert(Mod.Item.ROTTEN_APPLE.Worms, Mod.Trinket.HAMMERHEAD_WORM.ID)
	Mod.HeartGroups.Soul[Mod.Pickup.MOON_HEART.ID] = true
	Mod.HeartAmount[Mod.Pickup.MOON_HEART.ID] = 2
	Mod.HeartGroups.Soul[Mod.Pickup.MOON_HEART.ID_HALF] = true
	Mod.HeartAmount[Mod.Pickup.MOON_HEART.ID_HALF] = 1
end

patches:RegisterPatch("Furtherance", furtherancePatch)
