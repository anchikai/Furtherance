--Full credit to Epiphany
local Mod = Furtherance

---@param collectibleId CollectibleType
---@return boolean
---@function
function Furtherance:IsTechnicalPassive(collectibleId)
	if collectibleId == CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE
		or collectibleId == CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE
		or collectibleId == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES
	then
		return true
	else
		return false
	end
end

---Returns a dictionary of all passive items and how any of the item the player has.
---@param player EntityPlayer
---@param noFamiliar? boolean @If true, list will not include familiar items
---@return {[CollectibleType]: integer}
---@function
function Furtherance:GetPassiveItemDict(player, noFamiliar)
	local ret = {}

	for _, historyItem in ipairs(player:GetHistory():GetCollectiblesHistory()) do
		if historyItem:IsTrinket() then goto skipTrinket end
		local itemID = historyItem:GetItemID()
		local item = Mod.ItemConfig:GetCollectible(historyItem:GetItemID())
		if item
			and item.Type ~= ItemType.ITEM_ACTIVE
			and (not noFamiliar or item.Type ~= ItemType.ITEM_FAMILIAR)
			and not Mod:IsTechnicalPassive(itemID)
		then
			local num_item = player:GetCollectibleNum(itemID, true)
			ret[itemID] = num_item
		end
		::skipTrinket::
	end

	return ret
end

---Returns a dictionary of all items and how any of the item the player has.
---@param player EntityPlayer
---@param noFamiliar? boolean @If true, list will not include familiar items
---@return {[CollectibleType]: integer}
---@function
function Furtherance:GetItemDict(player, noFamiliar)
	local ret = {}
	local itemId = 1
	while itemId <= CollectibleType.NUM_COLLECTIBLES or Mod.ItemConfig:GetCollectible(itemId) do
		local item = Mod.ItemConfig:GetCollectible(itemId)
		if item and (not noFamiliar or item.Type ~= ItemType.ITEM_FAMILIAR) then
			local num_item = player:GetCollectibleNum(itemId, true)
			if num_item > 0 then
				ret[itemId] = num_item
			end
		end
		itemId = itemId + 1
	end
	return ret
end

---Returns true if the item is a quest item, Tainted Forgtten's Recall, or Tainted ???'s Hold
---@param itemId CollectibleType
---@function
function Furtherance:IsQuestItem(itemId)
	local config = Mod.ItemConfig
	local itemCfg = config:GetCollectible(itemId)

	return itemCfg and itemCfg:HasTags(ItemConfig.TAG_QUEST)
	or itemId == CollectibleType.COLLECTIBLE_RECALL
	or itemId == CollectibleType.COLLECTIBLE_HOLD
end

-- A set of items that give nothing but an HP up
Furtherance.BASIC_HP_UPS = Mod:Set({
	CollectibleType.COLLECTIBLE_HEART,
	CollectibleType.COLLECTIBLE_SNACK,
	CollectibleType.COLLECTIBLE_BREAKFAST,
	CollectibleType.COLLECTIBLE_DESSERT,
	CollectibleType.COLLECTIBLE_DINNER,
	CollectibleType.COLLECTIBLE_LUNCH,
	CollectibleType.COLLECTIBLE_ROTTEN_MEAT,
	CollectibleType.COLLECTIBLE_MIDNIGHT_SNACK,
	CollectibleType.COLLECTIBLE_SUPPER,
	CollectibleType.COLLECTIBLE_MAGIC_SCAB,
	CollectibleType.COLLECTIBLE_CRACK_JACKS,
	CollectibleType.COLLECTIBLE_STEM_CELLS,
})

-- Get every item that gives nothing but an HP up
---@param item CollectibleType
---@function
function Furtherance:IsBasicHpUp(item)
	return Furtherance.BASIC_HP_UPS[item] ~= nil
end

---Returns true if item with given id is an active item
---@param id CollectibleType
---@return boolean
---@function
function Furtherance:IsActiveItem(id)
	local config = Mod.ItemConfig
	local cfg = config:GetCollectible(id)
	return cfg and cfg.Type == ItemType.ITEM_ACTIVE
end

---Returns the Quality of the Collectible
---@param ID CollectibleType
---@return integer
---@function
function Furtherance:GetItemQuality(ID)
	return Mod.ItemConfig:GetCollectible(ID).Quality
end

---@param id Card
---@return string
---@function
function Furtherance:GetCardName(id)
	return Mod:TryGetTranslatedString("Cards", Isaac.GetItemConfig():GetCard(id).Name)
end

---@param id PillEffect
---@return string
---@function
function Furtherance:GetPillEffectName(id)
	return Mod:TryGetTranslatedString("Pills", Isaac.GetItemConfig():GetPillEffect(id).Name)
end

---@param id CollectibleType
---@return string
---@function
function Furtherance:GetCollectibleName(id)
	return Mod:TryGetTranslatedString("Items", Isaac.GetItemConfig():GetCollectible(id).Name)
end