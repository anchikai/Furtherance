local Mod = Furtherance

local BRUNCH = {}

Furtherance.Item.BRUNCH = BRUNCH

BRUNCH.ID = Isaac.GetItemIdByName("Brunch")

BRUNCH.SHOTSPEED_UP = 0.16

---@param player EntityPlayer
function BRUNCH:GetBrunch(player)
	if player:HasCollectible(BRUNCH.ID) then
		player.ShotSpeed = player.ShotSpeed + (BRUNCH.SHOTSPEED_UP * player:GetCollectibleNum(BRUNCH.ID))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BRUNCH.GetBrunch, CacheFlag.CACHE_SHOTSPEED)
