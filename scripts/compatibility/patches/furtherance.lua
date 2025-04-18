local Mod = Furtherance
local patches = Mod.PatchesLoader

local function furtherancePatch()
	Mod:Insert(Mod.Item.ROTTEN_APPLE.WORMS, Mod.Trinket.SLICK_WORM.ID)
	Mod:Insert(Mod.Item.ROTTEN_APPLE.WORMS, Mod.Trinket.HAMMERHEAD_WORM.ID)
end

patches:RegisterPatch("Furtherance", furtherancePatch)