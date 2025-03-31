local Mod = Furtherance

local ACE_OF_SHIELDS = {}

Furtherance.Card.ACE_OF_SHIELDS = ACE_OF_SHIELDS

ACE_OF_SHIELDS.ID = Isaac.GetCardIdByName("Ace of Shields")

ACE_OF_SHIELDS.BlacklistedPickupVariants = Mod:Set({
	PickupVariant.PICKUP_BROKEN_SHOVEL,
	PickupVariant.PICKUP_BED,
	PickupVariant.PICKUP_MOMSCHEST
})

function ACE_OF_SHIELDS:OnUse(_, player)
	for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		if not ACE_OF_SHIELDS.BlacklistedPickupVariants[ent.Variant] then
			local pickup = ent:ToPickup()
			---@cast pickup EntityPickup
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO)
		end
	end
	Mod:ForEachEnemy(function(npc)
		if not npc:IsBoss() then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO,
				npc.Position, Vector.Zero, nil)
			npc:Remove()
		end
	end, false)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ACE_OF_SHIELDS.OnUse, ACE_OF_SHIELDS.ID)
