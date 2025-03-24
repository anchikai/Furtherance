local Mod = Furtherance

local BOOK_OF_LEVITICUS = {}

Furtherance.Item.BOOK_OF_LEVITICUS = BOOK_OF_LEVITICUS

BOOK_OF_LEVITICUS.ID = Isaac.GetItemIdByName("Book of Leviticus")
BOOK_OF_LEVITICUS.USE_FLAGS = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOCOSTUME | UseFlag.USE_ALLOWWISPSPAWN

---@param player EntityPlayer
function BOOK_OF_LEVITICUS:UseBookOfLeviticus(_, _, player)
	player:UseCard(Card.CARD_REVERSE_TOWER, BOOK_OF_LEVITICUS.USE_FLAGS)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BOOK_OF_LEVITICUS.UseBookOfLeviticus, BOOK_OF_LEVITICUS.ID)
