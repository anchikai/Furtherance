local mod = Furtherance
local rng = RNG()

---@param collider Entity
function mod:CollectHeart(pickup, collider)
	local player = collider:ToPlayer()
	if player
		and player:HasTrinket(TrinketType.TRINKET_HOLY_HEART, false)
		and (player:CanPickSoulHearts()
		or pickup.SubType == HeartSubType.HEART_ETERNAL
		or (pickup.SubType == HeartSubType.HEART_BLENDED
			and player:CanPickRedHearts())
		)
	then
		if pickup.SubType == HeartSubType.HEART_ETERNAL then
			if rng:RandomInt(3) == 1 then
				player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			end
		elseif pickup.SubType == HeartSubType.HEART_SOUL then
			if rng:RandomInt(20) == 1 then
				player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			end
		elseif pickup.SubType == HeartSubType.HEART_BLENDED then
			if rng:RandomInt(20) == 1 then
				player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			end
		elseif pickup.SubType == HeartSubType.HEART_HALF_SOUL then
			if rng:RandomInt(50) == 1 then
				player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			end
		end
	end
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, mod.CollectHeart, PickupVariant.PICKUP_HEART)
