local Mod = Furtherance

local LEAHS_HEART = {}

Furtherance.Item.LEAHS_HEART = LEAHS_HEART

LEAHS_HEART.ID = Isaac.GetItemIdByName("Leah's Heart")

LEAHS_HEART.DAMAGE_MULT = 1.2

---@param player EntityPlayer
function LEAHS_HEART:OnActiveuse(_, _, player)
	local player_floor_save = Mod:FloorSave(player)
	if not player_floor_save.LeahsHeartUsedActive and player:HasCollectible(LEAHS_HEART.ID) then
		player_floor_save.LeahsHeartUsedActive = true
		player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
		player:AddSoulHearts(2)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.EARLY, LEAHS_HEART.OnActiveuse)

---@param player EntityPlayer
function LEAHS_HEART:HeartDamage(player)
	local player_floor_save = Mod:FloorSave(player)
	if player:HasCollectible(LEAHS_HEART.ID) and not player_floor_save.LeahsHeartUsedActive then
		player.Damage = player.Damage * 1.2
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LEAHS_HEART.HeartDamage, CacheFlag.CACHE_DAMAGE)
