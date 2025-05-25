local Mod = Furtherance

local ASTRAGALI = {}

Furtherance.Item.ASTRAGALI = ASTRAGALI

ASTRAGALI.ID = Isaac.GetItemIdByName("Astragali")

---@type {[PickupVariant]: fun(): boolean}
ASTRAGALI.ChestToAchievement = {
	[PickupVariant.PICKUP_WOODENCHEST] = function() return Mod.PersistGameData:Unlocked(Achievement.WOODEN_CHEST) end,
	[PickupVariant.PICKUP_MEGACHEST] = function() return Mod.PersistGameData:Unlocked(Achievement.MEGA_CHEST) end,
	[PickupVariant.PICKUP_HAUNTEDCHEST] = function() return Mod.PersistGameData:Unlocked(Achievement.HAUNTED_CHEST) end
}

---@param variant PickupVariant
function ASTRAGALI:IsChestAvailable(variant)
	local achievement = ASTRAGALI.ChestToAchievement[variant]
	return not achievement or achievement()
end

ASTRAGALI.Chests = {
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_BOMBCHEST,
	PickupVariant.PICKUP_SPIKEDCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_MIMICCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_MEGACHEST,
	PickupVariant.PICKUP_HAUNTEDCHEST,
	PickupVariant.PICKUP_LOCKEDCHEST,
	PickupVariant.PICKUP_REDCHEST,
}

ASTRAGALI.IsChest = Mod:Set(ASTRAGALI.Chests)

---@param player EntityPlayer
---@param flags UseFlag
function ASTRAGALI:UseAstragali(_, _, player, flags)
	if Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then return end
	local rng = player:GetCollectibleRNG(ASTRAGALI.ID)
	local rerollChestList = {}
	for _, chestVariant in ipairs(ASTRAGALI.Chests) do
		if ASTRAGALI:IsChestAvailable(chestVariant) then
			Mod.Insert(rerollChestList, chestVariant)
		end
	end
	Mod.Foreach.Pickup(function(pickup, index)
		if ASTRAGALI.IsChest[pickup.Variant] and pickup.SubType == ChestSubType.CHEST_CLOSED then
			local choice = rerollChestList[rng:RandomInt(#rerollChestList) + 1]
			pickup:Morph(EntityType.ENTITY_PICKUP, choice, ChestSubType.CHEST_CLOSED)
		end
	end)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ASTRAGALI.UseAstragali, ASTRAGALI.ID)
