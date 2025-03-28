local Mod = Furtherance

local ABYSSAL_PENNY = {}

Furtherance.Trinket.ABYSSAL_PENNY = ABYSSAL_PENNY

ABYSSAL_PENNY.ID = Isaac.GetTrinketIdByName("Abyssal Penny")

function ABYSSAL_PENNY:CollectCoin(pickup, collider)
	local player = collider:ToPlayer()
	if player and player:HasTrinket(ABYSSAL_PENNY.ID) and pickup:IsDead() then
		local water = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0,
			pickup.Position, Vector.Zero, player):ToEffect()
		---@cast water EntityEffect
		water.Scale = 1.5
		water.Size = water.Size * 1.5
		water:Update()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, ABYSSAL_PENNY.CollectCoin, PickupVariant.PICKUP_COIN)
