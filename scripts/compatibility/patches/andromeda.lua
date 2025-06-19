local Mod = Furtherance
local loader = Mod.PatchesLoader

local function andromedaPatch()
	Mod.API:RegisterAltruismCoinBeggar(Isaac.GetEntityVariantByName("Wisp Wizard"))
end

loader:RegisterPatch("ANDROMEDA", andromedaPatch)
