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
	Mod.Foreach.Pickup(function (pickup, index)
		if not ACE_OF_SHIELDS.BlacklistedPickupVariants[pickup.Variant] then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO)
		end
	end)

	Mod.Foreach.NPC(function (npc, index)
		if not npc:IsBoss() and npc:IsActiveEnemy(false) then
			Mod.Spawn.Battery(BatterySubType.BATTERY_MICRO, npc.Position, nil, nil, npc:GetDropRNG():GetSeed())
			npc:Remove()
		end
	end, nil, nil, nil, {Inverse = true, UseEnemySearchParams = true})
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ACE_OF_SHIELDS.OnUse, ACE_OF_SHIELDS.ID)
