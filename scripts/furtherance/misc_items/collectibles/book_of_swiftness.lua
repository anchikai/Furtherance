local Mod = Furtherance

local BOOK_OF_SWIFTNESS = {}

Furtherance.Item.BOOK_OF_SWIFTNESS = BOOK_OF_SWIFTNESS

BOOK_OF_SWIFTNESS.ID = Isaac.GetItemIdByName("Book of Swiftness")
BOOK_OF_SWIFTNESS.GIANTBOOK = Isaac.GetGiantBookIdByName("Book of Swiftness")

---@param player EntityPlayer
function BOOK_OF_SWIFTNESS:UseBookOfSwiftness(_, _, player)
	player:UseCard(Card.CARD_ERA_WALK, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BOOK_OF_SWIFTNESS.UseBookOfSwiftness, BOOK_OF_SWIFTNESS.ID)
