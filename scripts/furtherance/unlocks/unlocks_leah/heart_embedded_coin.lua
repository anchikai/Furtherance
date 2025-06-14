local Mod = Furtherance

local HEART_EMBEDDED_COIN = {}

Furtherance.Item.HEART_EMBEDDED_COIN = HEART_EMBEDDED_COIN

HEART_EMBEDDED_COIN.ID = Isaac.GetItemIdByName("Heart Embedded Coin")

---@param pickup EntityPickup
---@param collider Entity
function HEART_EMBEDDED_COIN:HeartsToCoins(pickup, collider)
	local player = collider:ToPlayer()
	if not (player
		and player:HasCollectible(HEART_EMBEDDED_COIN.ID)
		and Mod.HeartGroups.Red[pickup.SubType])
	then
		return
	end
	local amount = Mod.Item.HEART_RENOVATOR:CannotPickRedHeartsOrWillOverflow(pickup, player)

	if amount then
		player:AddCoins(amount + (player:GetCollectibleNum(HEART_EMBEDDED_COIN.ID) - 1))
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.EARLY, HEART_EMBEDDED_COIN.HeartsToCoins, PickupVariant.PICKUP_HEART)
