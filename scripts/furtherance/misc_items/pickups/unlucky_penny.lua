local Mod = Furtherance

local UNLUCKY_PENNY = {}

Furtherance.Pickup.UNLUCKY_PENNY = UNLUCKY_PENNY

UNLUCKY_PENNY.ID = Isaac.GetEntitySubTypeByName("Unlucky Penny")
UNLUCKY_PENNY.NULL_ID = Isaac.GetNullItemIdByName("unlucky penny")

UNLUCKY_PENNY.REPLACE_CHANCE = 0.25

Mod:RegisterReplacement({
	OldType = Mod:Set({ EntityType.ENTITY_PICKUP }),
	OldVariant = Mod:Set({ PickupVariant.PICKUP_COIN }),
	OldSubtype = Mod:Set({ CoinSubType.COIN_LUCKYPENNY }),
	NewType = EntityType.ENTITY_PICKUP,
	NewVariant = PickupVariant.PICKUP_COIN,
	NewSubtype = UNLUCKY_PENNY.ID,
	ReplacementChance = UNLUCKY_PENNY.REPLACE_CHANCE
})

---@param pickup EntityPickup
---@param collider Entity
function UNLUCKY_PENNY:UnluckyPenny(pickup, collider)
	local player = collider:ToPlayer()
	if player and pickup.SubType == UNLUCKY_PENNY.ID then
		Mod.SFXMan:Play(SoundEffect.SOUND_LUCKYPICKUP, 1, 2, false, 0.8)
		player:AddNullItemEffect(UNLUCKY_PENNY.NULL_ID, false)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, UNLUCKY_PENNY.UnluckyPenny, PickupVariant.PICKUP_COIN)

---@param pickup EntityPickup
function UNLUCKY_PENNY:PickupSound(pickup)
	if pickup.SubType == UNLUCKY_PENNY.ID and pickup:GetSprite():IsEventTriggered("DropSound") then
		Mod.SFXMan:Play(SoundEffect.SOUND_PENNYDROP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, UNLUCKY_PENNY.PickupSound, PickupVariant.PICKUP_COIN)

---@param player EntityPlayer
---@param flag CacheFlag
function UNLUCKY_PENNY:Lucknt(player, flag)
	local numEffects = player:GetEffects():GetNullEffectNum(UNLUCKY_PENNY.NULL_ID)
	if numEffects == 0 then return end

	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + (numEffects / 2)
	end
	if flag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck - numEffects
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, UNLUCKY_PENNY.Lucknt, CacheFlag.CACHE_DAMAGE)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, UNLUCKY_PENNY.Lucknt, CacheFlag.CACHE_LUCK)
