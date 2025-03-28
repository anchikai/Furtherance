local Mod = Furtherance

function Mod:GetRaincoat(player, flag)
	local numRaincoats = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LITTLE_RAINCOAT)
	if numRaincoats > 0 then
		player.SpriteScale = player.SpriteScale * 0.8 ^ numRaincoats
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.GetRaincoat, CacheFlag.CACHE_SIZE)

function Mod:RerollFood(pickup)
	local rng = RNG()
	local changeFood = rng:RandomFloat()
	if changeFood <= 0.06 then
		if Isaac.GetItemConfig():GetCollectible(pickup.SubType).Tags & ItemConfig.TAG_FOOD ~= 0 then
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_NULL,
				false, false, false)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Mod.RerollFood, PickupVariant.PICKUP_COLLECTIBLE)

local damageCounter = 0
function Mod:RaincoatDamage(entity)
	local player = entity:ToPlayer()
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_RAINCOAT) then
		damageCounter = damageCounter + 1
		if damageCounter >= 6 then
			player:UsePill(PillEffect.PILLEFFECT_POWER, PillColor.PILL_NULL,
			UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
			damageCounter = 0
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.RaincoatDamage, EntityType.ENTITY_PLAYER)

function Mod:ResetCounter(continued)
	if continued == false then
		damageCounter = 0
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.ResetCounter)
