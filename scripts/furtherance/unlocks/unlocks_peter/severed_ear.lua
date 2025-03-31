local Mod = Furtherance

local SEVERED_EAR = {}

Furtherance.Item.SEVERED_EAR = SEVERED_EAR

SEVERED_EAR.ID = Isaac.GetItemIdByName("Severed Ear")

SEVERED_EAR.DAMAGE_MULT_UP = 1.2
SEVERED_EAR.FIRE_DELAY_DIV_DOWN = 0.8
SEVERED_EAR.RANGE_MULT_UP = 1.2
SEVERED_EAR.SHOTSPEED_MULT_DOWN = 0.6

---@param player EntityPlayer
---@param flag CacheFlag
function SEVERED_EAR:GetSeveredEar(player, flag)
	if player:HasCollectible(SEVERED_EAR.ID) then
		local num = player:GetCollectibleNum(SEVERED_EAR.ID)
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * SEVERED_EAR.DAMAGE_MULT_UP
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay / (SEVERED_EAR.FIRE_DELAY_DIV_DOWN / num)
		end
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + (Furtherance.RANGE_BASE_MULT*  SEVERED_EAR.RANGE_MULT_UP * num)
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - (SEVERED_EAR.SHOTSPEED_MULT_DOWN * num)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SEVERED_EAR.GetSeveredEar)
