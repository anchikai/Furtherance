local Mod = Furtherance
local loader = Mod.PatchesLoader

local function arachnaPatch()
	Mod.API:RegisterAltruismCoinBeggar(Isaac.GetEntityVariantByName("Spiderboi (beggar)"))
end

loader:RegisterPatch("ARACHNAMOD", arachnaPatch)