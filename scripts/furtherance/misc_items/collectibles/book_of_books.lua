--TODO: Insanely OP. Awaiting reply from anchikai

local Mod = Furtherance

local BOOK_OF_BOOKS = {}

Furtherance.Item.BOOK_OF_BOOKS = BOOK_OF_BOOKS

BOOK_OF_BOOKS.ID = Isaac.GetItemIdByName("Book of Books")
BOOK_OF_BOOKS.GIANTBOOK = Isaac.GetGiantBookIdByName("Book of Books")

---@param player EntityPlayer
function BOOK_OF_BOOKS:OnUse(_, _, player)
	local bookItemConfigs = Mod.ItemConfig:GetTaggedItems(ItemConfig.TAG_BOOK)
	local bookItemIDs = {}
	for _, itemConfig in ipairs(bookItemConfigs) do
		if itemConfig.Type == ItemType.ITEM_ACTIVE
			and not itemConfig:HasTags(ItemConfig.TAG_QUEST)
			and itemConfig.ID ~= BOOK_OF_BOOKS.ID
		then
			Mod:Insert(bookItemIDs)
		end
	end
	for _, itemID in ipairs(bookItemIDs) do
		player:UseActiveItem(itemID, false, false, true, true, -1)
	end

	ItemOverlay.Show(BOOK_OF_BOOKS.GIANTBOOK)

	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BOOK_OF_BOOKS.OnUse, BOOK_OF_BOOKS.ID)
