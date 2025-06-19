local Mod = Furtherance
local loader = Mod.PatchesLoader

local function punishedPatch()
	Mod.API:RegisterAltruismHurtBeggar(Isaac.GetEntityVariantByName("Red Beggar"))
end

loader:RegisterPatch("ThePunished", punishedPatch)