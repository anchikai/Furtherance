local Mod = Furtherance
local game = Game()

local whitelistedPickupVariants = {
	[PickupVariant.PICKUP_COLLECTIBLE] = true,
	[PickupVariant.PICKUP_SHOPITEM] = true,
	[PickupVariant.PICKUP_BIGCHEST] = true,
	[PickupVariant.PICKUP_TROPHY] = true,
	[PickupVariant.PICKUP_BED] = true,
	[PickupVariant.PICKUP_MOMSCHEST] = true,
	[PickupVariant.PICKUP_THROWABLEBOMB] = true,
}

function Mod:UseAceOfShields(_, player)
	local room = game:GetRoom()
	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		local pickup = entity:ToPickup()
		if pickup and not whitelistedPickupVariants[pickup.Variant] then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO)
		elseif entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() and not entity:IsBoss() then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO,
				entity.Position, Vector.Zero, nil)
			entity:Remove()
		end
		room:SetClear(true)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, Mod.UseAceOfShields, CARD_ACE_OF_SHIELDS)
