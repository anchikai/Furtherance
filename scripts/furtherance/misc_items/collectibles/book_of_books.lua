local Mod = Furtherance

local BOOK_OF_BOOKS = {}

Furtherance.Item.BOOK_OF_BOOKS = BOOK_OF_BOOKS

BOOK_OF_BOOKS.ID = Isaac.GetItemIdByName("Book of Books")
BOOK_OF_BOOKS.GIANTBOOK = Isaac.GetGiantBookIdByName("Book of Books")

---@param rng RNG
---@param player EntityPlayer
function BOOK_OF_BOOKS:OnUse(_, rng, player)
	local bookItemConfigs = Mod.ItemConfig:GetTaggedItems(ItemConfig.TAG_BOOK)
	local bookItemIDs = {}
	for _, itemConfig in ipairs(bookItemConfigs) do
		if itemConfig.Type == ItemType.ITEM_ACTIVE
			and not itemConfig:HasTags(ItemConfig.TAG_QUEST)
			and itemConfig.ID ~= BOOK_OF_BOOKS.ID
			and Mod.PersistGameData:Unlocked(itemConfig.AchievementID)
		then
			Mod.Insert(bookItemIDs, itemConfig.ID)
		end
	end
	player:UseActiveItem(bookItemIDs[rng:RandomInt(#bookItemIDs) + 1], false, false, true, true, -1)

	ItemOverlay.Show(BOOK_OF_BOOKS.GIANTBOOK)

	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BOOK_OF_BOOKS.OnUse, BOOK_OF_BOOKS.ID)
