local Mod = Furtherance

local REVERSE_CHARITY = {}

Furtherance.Card.REVERSE_CHARITY = REVERSE_CHARITY

REVERSE_CHARITY.ID = Isaac.GetCardIdByName("ReverseCharity")

local makeShopItem = false

---@param player EntityPlayer
function REVERSE_CHARITY:OnUse(card, player, flag)
	makeShopItem = true
	player:UseActiveItem(CollectibleType.COLLECTIBLE_DIPLOPIA, false, false, false, false, -1)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, REVERSE_CHARITY.OnUse, REVERSE_CHARITY.ID)

---@param pickup EntityPickup
function REVERSE_CHARITY:OnPickupInit(pickup)
	if makeShopItem then
		pickup:MakeShopItem(-1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, REVERSE_CHARITY.OnPickupInit)

function REVERSE_CHARITY:OnDiplopiaUse()
	makeShopItem = false
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, REVERSE_CHARITY.OnDiplopiaUse, CollectibleType.COLLECTIBLE_DIPLOPIA)
