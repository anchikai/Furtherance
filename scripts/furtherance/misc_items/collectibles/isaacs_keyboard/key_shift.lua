local Mod = Furtherance

local SHIFT_KEY = {}

Furtherance.Item.KEY_SHIFT = SHIFT_KEY

SHIFT_KEY.ID = Isaac.GetItemIdByName("Shift Key")

SHIFT_KEY.MAX_COOLDOWN = Mod.ItemConfig:GetCollectible(SHIFT_KEY.ID).MaxCooldown
SHIFT_KEY.DAMAGE_BONUS = 15

---@param player EntityPlayer
function SHIFT_KEY:OnUse(_, _, player)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, SHIFT_KEY.OnUse, SHIFT_KEY.ID)

---@param player EntityPlayer
function SHIFT_KEY:DamageDecrease(player)
	-- every 0.5 seconds
	local effects = player:GetEffects()
	if effects:HasCollectibleEffect(SHIFT_KEY.ID) and effects:GetCollectibleEffect(SHIFT_KEY.ID).Cooldown % 15 == 0 then
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SHIFT_KEY.DamageDecrease)

---@param player EntityPlayer
function SHIFT_KEY:ShiftBuffs(player)
	local effects = player:GetEffects()
	if effects:HasCollectibleEffect(SHIFT_KEY.ID) then
		player.Damage = player.Damage + (effects:GetCollectibleEffect(SHIFT_KEY.ID).Cooldown / SHIFT_KEY.MAX_COOLDOWN) * SHIFT_KEY.DAMAGE_BONUS
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SHIFT_KEY.ShiftBuffs, CacheFlag.CACHE_DAMAGE)
