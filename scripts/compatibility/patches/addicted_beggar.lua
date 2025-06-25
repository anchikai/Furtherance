local Mod = Furtherance
local loader = Mod.PatchesLoader

local function addictedBeggarPatch()
	Mod.API:RegisterAltruismCoinBeggar(Isaac.GetEntityVariantByName("Addicted Beggar"), 1, true)
end

loader:RegisterPatch(function() return Isaac.GetEntityVariantByName("Addicted Beggar") ~= -1 end, addictedBeggarPatch, "Addicted Beggar")