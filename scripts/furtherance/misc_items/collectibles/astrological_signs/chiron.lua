local Mod = Furtherance

local CHIRON = {}

Furtherance.Item.CHIRON = CHIRON

CHIRON.ID = Isaac.GetItemIdByName("Chiron?")

CHIRON.SPEED_UP = 0.2

---@type fun(level: Level)[]
CHIRON.MAP_EFFECTS = {
	function(level) level:ApplyCompassEffect(true) end,
	function(level) level:ApplyMapEffect() end,
	function(level) level:ApplyBlueMapEffect() end
}

-- Thank you for all the fixes manaphoenix!

---@param player EntityPlayer
function CHIRON:ChironMapping(player) -- Apply a random map effect every floor
	if player:HasCollectible(CHIRON.ID) then
		local level = Mod.Level()
		local rng = player:GetCollectibleRNG(CHIRON.ID)
		if level:GetStateFlag(LevelStateFlag.STATE_COMPASS_EFFECT) then
			CHIRON.MAP_EFFECTS[1] = nil
		end
		if level:GetStateFlag(LevelStateFlag.STATE_MAP_EFFECT) then
			CHIRON.MAP_EFFECTS[2] = nil
		end
		if level:GetStateFlag(LevelStateFlag.STATE_BLUE_MAP_EFFECT) then
			CHIRON.MAP_EFFECTS[3] = nil
		end
		---@type fun(level: Level)[]
		local effectOptions = {}
		for _, func in pairs(CHIRON.MAP_EFFECTS) do
			Mod.Insert(effectOptions, func)
		end
		for _ = 1, player:GetCollectibleNum(CHIRON.ID) do
			if #effectOptions == 0 then return end
			local roll = rng:RandomInt(#effectOptions) + 1

			local mapEffect = effectOptions[roll]
			if mapEffect then
				mapEffect(level)
			end
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

	if player:HasCollectible(CHIRON.ID) and room:IsFirstVisit() and room:GetFrameCount() == 1 then
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
			Mod.Insert(validBooks, itemConfig.ID)
		end
	end
	return validBooks
end

---@param player EntityPlayer
function CHIRON:BossBook(player)
	local books = CHIRON:GetOffensiveBooks()
	if #books == 0 then return end
	local rng = player:GetCollectibleRNG(CHIRON.ID)
	for _ = 1, player:GetCollectibleNum(CHIRON.ID) do
		local randomNum = rng:RandomInt(#books) + 1
		local rollBook = books[randomNum]
		if not rollBook then return end
		table.remove(books, randomNum)
		player:UseActiveItem(rollBook, true, false, true, true, -1)
	end
end

---@param player EntityPlayer
function CHIRON:GetChiron(player)
	if player:HasCollectible(CHIRON.ID) then
		player.MoveSpeed = player.MoveSpeed + (CHIRON.SPEED_UP * player:GetCollectibleNum(CHIRON.ID))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CHIRON.GetChiron, CacheFlag.CACHE_SPEED)
