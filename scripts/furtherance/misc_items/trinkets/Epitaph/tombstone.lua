local Mod = Furtherance

local TOMBSTONE = {}

TOMBSTONE.ID = Isaac.GetEntityVariantByName("Epitaph Tombstone")

---@param player EntityPlayer
function TOMBSTONE:SpawnTombstone(player)
	local gridEffect
	local grid_save = Mod:RoomSave()
end

---@param ent Entity
---@param amount integer
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function TOMBSTONE:OnTakeDMG(ent, amount, flags, source, countdown)
	if ent.Variant == TOMBSTONE.ID then
		local sprite = ent:GetSprite()
		if ent.HitPoints > 0 then
			sprite:Play("Damaged" .. ent.HitPoints)
		else
			sprite:Play("Destroyed")
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, TOMBSTONE.OnTakeDMG, EntityType.ENTITY_EFFECT)

---@param player EntityPlayer
---@param effect EntityEffect
function TOMBSTONE:Die(player, effect)
	local rng = self.Owner:GetTrinketRNG(Mod.Trinket.EPITAPH.ID)
	local coinCount = rng:RandomInt(3) + 3

	for _ = 1, coinCount do
		local velocity = EntityPickup.GetRandomPickupVelocity(effect.Position, rng)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY,
			effect.Position, velocity, effect)
	end

	local keyCount = rng:RandomInt(2) + 2
	for _ = 1, keyCount do
		local velocity = EntityPickup.GetRandomPickupVelocity(effect.Position, rng)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, effect.Position,
			velocity, effect)
	end

	local ownerData = Mod:GetData(self.Owner)
	if ownerData.EpitaphFirstPassiveItem then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ownerData.EpitaphFirstPassiveItem,
			Isaac.GetFreeNearPosition(effect.Position, 40), Vector.Zero, effect)
	end
	if ownerData.EpitaphLastPassiveItem then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ownerData.EpitaphLastPassiveItem,
			Isaac.GetFreeNearPosition(effect.Position, 40), Vector.Zero, effect)
	end

	ownerData.EpitaphTombstoneDestroyed = true
end

return TOMBSTONE
