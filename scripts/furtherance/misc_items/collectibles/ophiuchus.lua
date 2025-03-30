local Mod = Furtherance

local OPHIUCHUS = {}

Furtherance.Item.OPHIUCHUS = OPHIUCHUS

OPHIUCHUS.ID = Isaac.GetItemIdByName("Ophiuchus")

OPHIUCHUS.DAMAGE_UP = 0.3
OPHIUCHUS.FIREDELAY_DOWN = 0.4

---@param player EntityPlayer
---@param flag CacheFlag
function OPHIUCHUS:OphiuchusStats(player, flag)
	if player:HasCollectible(OPHIUCHUS.ID) then
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPECTRAL
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + (OPHIUCHUS.DAMAGE * player:GetCollectibleNum(OPHIUCHUS.ID))
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay - (OPHIUCHUS.FIREDELAY_DOWN  * player:GetCollectibleNum(OPHIUCHUS.ID))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, OPHIUCHUS.OphiuchusStats)
