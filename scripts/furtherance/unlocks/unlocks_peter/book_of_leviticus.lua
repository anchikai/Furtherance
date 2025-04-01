local Mod = Furtherance

local BOOK_OF_LEVITICUS = {}

Furtherance.Item.BOOK_OF_LEVITICUS = BOOK_OF_LEVITICUS

BOOK_OF_LEVITICUS.ID = Isaac.GetItemIdByName("Book of Leviticus")

---@param player EntityPlayer
function BOOK_OF_LEVITICUS:UseBookOfLeviticus(_, _, player)
	player:UseCard(Card.CARD_REVERSE_TOWER, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BOOK_OF_LEVITICUS.UseBookOfLeviticus, BOOK_OF_LEVITICUS.ID)
