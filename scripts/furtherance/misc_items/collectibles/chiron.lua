local mod = Furtherance
local game = Game()
local itemConfig = Isaac.GetItemConfig()

-- Thank you for all the fixes manaphoenix!

Furtherance:SaveModData({
	ChironBooks = {}
})

function mod:GetBooks(isContinued)
	if isContinued then return end
	for i = 1, #itemConfig:GetCollectibles() - 1 do
		local item = itemConfig:GetCollectible(i)
		if item
			and item.Type == ItemType.ITEM_ACTIVE
			and item:HasTags(ItemConfig.TAG_OFFENSIVE)
			and item:HasTags(ItemConfig.TAG_BOOK)
		then
			mod.ChironBooks[#mod.ChironBooks+1] = item.ID
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.GetBooks)

function mod:ChironMapping() -- Apply a random map effect every floor
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CHIRON) then
			local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CHIRON)
			local level = game:GetLevel()
			local rollMap = rng:RandomInt(3)
			if rollMap == 1 then
				level:ApplyCompassEffect(true)
			elseif rollMap == 2 then
				level:ApplyMapEffect()
			elseif rollMap == 3 then
				level:ApplyBlueMapEffect()
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.ChironMapping)

function mod:BossDetection() -- If the room is a boss room
	local room = game:GetRoom()
	if not room:IsCurrentRoomLastBoss() then
		return
	end -- check to make sure its a boss. if not, stop the rest of the checks/code

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CHIRON) and room:IsFirstVisit() == true and room:GetFrameCount() == 1 then -- Guwah you legend
			mod:BossBook(player)                                                                                                        -- Use a random book
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.BossDetection)

---@param player EntityPlayer
function mod:BossBook(player) -- Roll a random book effect
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CHIRON)
	local rollBook = mod.ChironBooks[rng:RandomInt(#mod.ChironBooks) + 1]
	if rollBook then
		player:UseActiveItem(rollBook, UseFlag.USE_NOANNOUNCER, -1)
	end
end

function mod:GetChiron(player, cacheFlag)          -- Speed up
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CHIRON) then
		if cacheFlag == CacheFlag.CACHE_SPEED then -- this is the correct way to compare bitflags :)
			player.MoveSpeed = player.MoveSpeed + 0.2
		end
	end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.GetChiron)
