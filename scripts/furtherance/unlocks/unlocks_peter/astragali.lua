local Mod = Furtherance

local ASTRAGALI = {}

Furtherance.Item.ASTRAGALI = ASTRAGALI

ASTRAGALI.ID = Isaac.GetItemIdByName("Astragali")

---@type {[PickupVariant]: Achievement}
ASTRAGALI.ChestToAchievement = {
	[PickupVariant.PICKUP_WOODENCHEST] = Achievement.WOODEN_CHEST,
	[PickupVariant.PICKUP_MEGACHEST] = Achievement.MEGA_CHEST,
	[PickupVariant.PICKUP_HAUNTEDCHEST] = Achievement.HAUNTED_CHEST
}

---@param variant PickupVariant
function ASTRAGALI:IsChestAvailable(variant)
	local achievement = ASTRAGALI.ChestToAchievement[variant]
	return achievement and Mod.PersistGameData:Unlocked(achievement) or not achievement and true
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

--TODO: Achievement cache maybe? And allow a better system for modded checks & unlockable or not but we'll worry about that later

---@param player EntityPlayer
---@param flags UseFlag
function ASTRAGALI:UseAstragali(_, _, player, flags)
	if Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then return end
	local rng = player:GetCollectibleRNG(ASTRAGALI.ID)
	local rerollChestList = {}
	for _, chestVariant in ipairs(ASTRAGALI.Chests) do
		if ASTRAGALI:IsChestAvailable(chestVariant) then
			Mod:Insert(rerollChestList, chestVariant)
		end
	end
	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		local pickup = entity:ToPickup()
		---@cast pickup EntityPickup
		if ASTRAGALI.IsChest[pickup.Variant] and pickup.SubType == ChestSubType.CHEST_CLOSED then
			local choice = rng:RandomInt(#rerollChestList) + 1
			pickup:Morph(EntityType.ENTITY_PICKUP, choice, ChestSubType.CHEST_CLOSED)
		end
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ASTRAGALI.UseAstragali, ASTRAGALI.ID)
