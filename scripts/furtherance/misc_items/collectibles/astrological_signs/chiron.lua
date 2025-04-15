local Mod = Furtherance

local CHIRON = {}

Furtherance.Item.CHIRON = CHIRON

CHIRON.ID = Isaac.GetItemIdByName("Chiron?")

CHIRON.SPEED_UP = 0.2

-- Thank you for all the fixes manaphoenix!

---@param player EntityPlayer
function CHIRON:ChironMapping(player) -- Apply a random map effect every floor
	if player:HasCollectible(CHIRON.ID) then
		local rng = player:GetCollectibleRNG(CHIRON.ID)
		local level = Mod.Level()
		local rollMap = rng:RandomInt(3)
		if rollMap == 0 then
			level:ApplyCompassEffect(true)
		elseif rollMap == 1 then
			level:ApplyMapEffect()
		elseif rollMap == 2 then
			level:ApplyBlueMapEffect()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, CHIRON.ChironMapping)

---@param player EntityPlayer
function CHIRON:UseBookOnLastBossEntry(player)
	local room = Mod.Room()
	if not room:IsCurrentRoomLastBoss() then
		return
	end

	if player:HasCollectible(CHIRON.ID) and room:IsFirstVisit() == true and room:GetFrameCount() == 1 then
		CHIRON:BossBook(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CHIRON.UseBookOnLastBossEntry)

function CHIRON:GetOffensiveBooks()
	local bookItemConfigs = Mod.ItemConfig:GetTaggedItems(ItemConfig.TAG_BOOK)
	local validBooks = {}
	for _, itemConfig in ipairs(bookItemConfigs) do
		if itemConfig.Type == ItemType.ITEM_ACTIVE
			and itemConfig:HasTags(ItemConfig.TAG_OFFENSIVE)
			and not itemConfig:HasTags(ItemConfig.TAG_QUEST)
			and Mod.PersistGameData:Unlocked(itemConfig.AchievementID)
		then
			Mod:Insert(validBooks)
		end
	end
	return validBooks
end

---@param player EntityPlayer
function CHIRON:BossBook(player) -- Roll a random book effect
	local books = CHIRON:GetOffensiveBooks()
	if #books == 0 then return end
	local rng = player:GetCollectibleRNG(CHIRON.ID)
	local rollBook = books[rng:RandomInt(#books) + 1]
	player:UseActiveItem(rollBook, true, false, true, true, -1)
end

---@param player EntityPlayer
function CHIRON:GetChiron(player)
	if player:HasCollectible(CHIRON.ID) then
		player.MoveSpeed = player.MoveSpeed + (CHIRON.SPEED_UP * player:GetCollectibleNum(CHIRON.ID))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CHIRON.GetChiron, CacheFlag.CACHE_SPEED)
