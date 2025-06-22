local Mod = Furtherance
local loader = Mod.PatchesLoader

local function punishedPatch()
	--Punished's beggar seems to be completely borked so this effectively does nothing
	Mod.API:RegisterAltruismHurtBeggar(Isaac.GetEntityVariantByName("Red Beggar"))
end

loader:RegisterPatch("ThePunished", punishedPatch)