local Mod = Furtherance

local CHARITY = {}

Furtherance.Card.CHARITY = CHARITY

CHARITY.ID = Isaac.GetCardIdByName("Charity")

---@param player EntityPlayer
function CHARITY:UseCharity(card, player, flag)
	for _ = 1, 3 do
		player:UseActiveItem(Mod.Item.JAR_OF_MANNA.ID, false, false, false, false, -1)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, CHARITY.UseCharity, CHARITY.ID)
