local Mod = Furtherance

local LITTLE_RAINCOAT = {}

Furtherance.Item.LITTLE_RAINCOAT = LITTLE_RAINCOAT

LITTLE_RAINCOAT.ID = Isaac.GetItemIdByName("Little Raincoat")

--TODO: Revisit for rework. Idea:
--every 6 hits triggers power pill effect
--increase power pill dmg to scale off of isaac's tear dmg with a bonus for every empty heart container
--killing an enemy with power pill has a 6% chance to gain 1 empty red heart container
--guarantees power pill will be in rotation
--tick rate also scales off of empty heart containers

--[[ function LITTLE_RAINCOAT:RaincoatSize(player, flag)
	local numRaincoats = player:GetCollectibleNum(LITTLE_RAINCOAT.ID)
	if numRaincoats > 0 then
		player.SpriteScale = player.SpriteScale * 0.8 ^ numRaincoats
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LITTLE_RAINCOAT.RaincoatSize, CacheFlag.CACHE_SIZE)

function LITTLE_RAINCOAT:OnFirstPickup(item, charge, firstTime, slot, varData, player)

end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, LITTLE_RAINCOAT.OnFirstPickup, LITTLE_RAINCOAT.ID)

---@param ent Entity
function LITTLE_RAINCOAT:RaincoatDamage(ent)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(LITTLE_RAINCOAT.ID) then
		local effects = player:GetEffects()
		if damageCounter >= 6 then
			player:UsePill(PillEffect.PILLEFFECT_POWER, PillColor.PILL_NULL,
			UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
			damageCounter = 0
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, LITTLE_RAINCOAT.RaincoatDamage, EntityType.ENTITY_PLAYER)
 ]]