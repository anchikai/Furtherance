local Mod = Furtherance

local THE_DREIDEL = {}

Furtherance.Item.THE_DREIDEL = THE_DREIDEL

THE_DREIDEL.ID = Isaac.GetItemIdByName("The Dreidel")

THE_DREIDEL.StatTable = {
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Debuff = 0.25 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Debuff = 0.5 },
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Debuff = 0.5 * Mod.RANGE_BASE_MULT },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Debuff = 0.25 },
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Debuff = 0.2 },
	{ Name = "Luck",         Flag = CacheFlag.CACHE_LUCK,      Debuff = 0.5 }
}

---@param rng RNG
---@param player EntityPlayer
function THE_DREIDEL:OnUse(_, rng, player)
	local selectedStats = {}
	local player_run_save = Mod:RunSave(player)
	local numStatsToReduce = rng:RandomInt(4) + 1

	player_run_save.DreidelStatDowns = player_run_save.DreidelStatDowns or {}

	for _ = 1, numStatsToReduce do
		local key = Mod:GetDifferentRandomKey(selectedStats, THE_DREIDEL.StatTable, rng)
		selectedStats[key] = true
		player_run_save.DreidelStatDowns[tostring(key)] = (player_run_save.DreidelStatDowns[tostring(key)] or 0) + 1
	end

	local itemPool = Mod.Game:GetItemPool()
	local itemID
	for _ = 1, 100 do
		itemID = itemPool:GetCollectible(itemPool:GetLastPool(), false, rng:GetSeed(), CollectibleType.COLLECTIBLE_BREAKFAST)
		local itemConfig = Mod.ItemConfig:GetCollectible(itemID)
		if itemConfig
			and itemConfig.Quality == numStatsToReduce
		then
			itemPool:RemoveCollectible(itemID)
			break
		else
			rng:Next()
		end
	end
	if itemID then
		Mod.Spawn.Collectible(itemID, Mod.Room():FindFreePickupSpawnPosition(player.Position, 40, true), player)
	end

	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)

	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, THE_DREIDEL.OnUse, THE_DREIDEL.ID)

---@param player EntityPlayer
function THE_DREIDEL:StatBuffs(player, flag)
	local player_run_save = Mod:RunSave(player)
	if not player_run_save.DreidelStatDowns then return end

	for i, statCount in pairs(player_run_save.DreidelStatDowns) do
		local stat = THE_DREIDEL.StatTable[tonumber(i)]

		if stat.Flag == flag then
			if flag == CacheFlag.CACHE_FIREDELAY then
				player[stat.Name] = Mod:TearsDown(player[stat.Name], statCount * stat.Debuff)
			elseif flag == CacheFlag.CACHE_DAMAGE then
				player[stat.Name] = player[stat.Name] - statCount * stat.Debuff * Mod:GetPlayerDamageMultiplier(player)
			else
				player[stat.Name] = player[stat.Name] - statCount * stat.Debuff
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, THE_DREIDEL.StatBuffs)
