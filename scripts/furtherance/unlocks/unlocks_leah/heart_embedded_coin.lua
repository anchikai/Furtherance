local Mod = Furtherance

--TODO: Could use a rename?
local HEART_EMBEDDED_COIN = {}

Furtherance.Item.HEART_EMBEDDED_COIN = HEART_EMBEDDED_COIN

HEART_EMBEDDED_COIN.ID = Isaac.GetItemIdByName("Heart Embedded Coin")

---@param pickup EntityPickup
---@param collider Entity
function HEART_EMBEDDED_COIN:HeartsToCoins(pickup, collider)
	local player = collider:ToPlayer()
	if not player or not player:HasCollectible(HEART_EMBEDDED_COIN.ID) then return end
	local amount = Mod.Item.HEART_RENOVATOR:CannotPickRedHeartsOrWillOverflow(pickup, player)

	if amount then
		player:AddCoins(amount)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, HEART_EMBEDDED_COIN.HeartsToCoins, PickupVariant.PICKUP_HEART)
