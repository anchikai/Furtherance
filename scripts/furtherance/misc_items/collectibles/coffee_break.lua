local Mod = Furtherance

local COFFEE_BREAK = {}

Furtherance.Item.COFFEE_BREAK = COFFEE_BREAK

COFFEE_BREAK.ID = Isaac.GetItemIdByName("Coffee Break")

COFFEE_BREAK.SPEED_UP = 0.2

---@param player EntityPlayer
function COFFEE_BREAK:GetCoffeeBreak(player)
	if player:HasCollectible(COFFEE_BREAK.ID) then
		player.MoveSpeed = player.MoveSpeed + (COFFEE_BREAK.SPEED_UP * player:GetCollectibleNum(COFFEE_BREAK.ID))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, COFFEE_BREAK.GetCoffeeBreak, CacheFlag.CACHE_SPEED)
