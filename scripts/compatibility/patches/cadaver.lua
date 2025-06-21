local Mod = Furtherance
local loader = Mod.PatchesLoader

local function cadaverPatch()
	local ROTTEN_CHEST = Isaac.GetEntityVariantByName("Rotten Chest")

	Mod.API:RegisterAstragaliChest(ROTTEN_CHEST, function() return CadaverAchievements.RottenChest end)

	local function correctRottenChestSelection(_, pickup)
		return pickup.SubType == 0 --For Rotten Chest, 1 is open, 0 is closed
	end

	Mod:AddCallback(Mod.ModCallbacks.ASTRAGALI_PRE_SELECT_CHEST, correctRottenChestSelection, ROTTEN_CHEST)

	local function correctRottenChestReroll(_, pickup, selectedVariant)
		return {EntityType.ENTITY_PICKUP, ROTTEN_CHEST, 0}
	end

	Mod:AddCallback(Mod.ModCallbacks.ASTRAGALI_PRE_REROLL_CHEST, correctRottenChestReroll, ROTTEN_CHEST)
end

loader:RegisterPatch("CadaverAchievements", cadaverPatch)
