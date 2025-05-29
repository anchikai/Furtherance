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
		local value = pickup:GetCoinValue()
		if value > 99 then
			value = 5
		end
		local BASE_DMG = 40
		local smallerMultiplier = (player:GetTrinketMultiplier(ABYSSAL_PENNY.ID) - 1) * 0.5
		local trinketMult = BASE_DMG * smallerMultiplier
		water.CollisionDamage = BASE_DMG + trinketMult
		water.Scale = 1.5 + (value * 0.1)
		water.Size = water.Size * 1.5 + (value * 0.1)
		water.Timeout = 90 + (30 * value)
		water:Update()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, ABYSSAL_PENNY.CollectCoin, PickupVariant.PICKUP_COIN)
