local Mod = Furtherance
local loader = Mod.PatchesLoader

local function retributionPatch()
	Mod.API:AddRottenAppleWormTrinket(Retribution.Trinket.HEART_WORM)
end

loader:RegisterPatch("Retribution", retributionPatch)