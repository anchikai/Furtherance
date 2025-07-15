local Mod = Furtherance
local loader = Mod.PatchesLoader

local function reshakenPatch()
	MilkshakeVol1.API:AddItemsToGlassPool({
		{
			Collectible = Mod.Item.POLYDIPSIA.ID,
			Weight = 1,
			DecreaseBy = 1,
			RemoveOn = 0.1,
			IsUnlocked = function() return Mod.PersistGameData:Unlocked(Mod.Item.POLYDIPSIA.ACHIEVEMENT) end
		},
		{
			Collectible = Mod.Item.TECH_IX.ID,
			Weight = 1,
			DecreaseBy = 1,
			RemoveOn = 0.1,
			IsUnlocked = function() return true end
		},
		{
			Collectible = Mod.Item.KERATOCONUS.ID,
			Weight = 1,
			DecreaseBy = 1,
			RemoveOn = 0.1,
			IsUnlocked = function() return Mod.PersistGameData:Unlocked(Mod.Item.KERATOCONUS.ACHIEVEMENT) end
		}
	})
end

loader:RegisterPatch("MilkshakeVol1", reshakenPatch, "TBoI: Reshaken")
