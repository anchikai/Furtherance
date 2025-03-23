local mod = Furtherance

function mod:CollectCoin(pickup, collider)
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		if player:HasTrinket(TrinketType.TRINKET_ABYSSAL_PENNY, false) then
			if collider:ToPlayer() then
				if pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL then
					local Water = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0,
						pickup.Position, Vector.Zero, player):ToEffect()
					---@cast Water EntityEffect
					Water.Scale = 2
					Water.Size = Water.Size * 2
				end
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.CollectCoin, PickupVariant.PICKUP_COIN)
