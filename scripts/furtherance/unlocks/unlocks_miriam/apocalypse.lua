local Mod = Furtherance

local APOCALYPSE = {}

Furtherance.Item.APOCALYPSE = APOCALYPSE

APOCALYPSE.ID = Isaac.GetItemIdByName("Apocalypse")

APOCALYPSE.StatTable = {
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Buff = 1 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Buff = 0.5 }, -- MaxFireDelay buffs should be negative!
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Buff = 0.25 * Mod.RANGE_BASE_MULT },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Buff = 0.1 },
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Buff = 0.1 },
	{ Name = "Luck",         Flag = CacheFlag.CACHE_LUCK,      Buff = 1 },
}

---@param player EntityPlayer
---@param rng RNG
function APOCALYPSE:UseApocalypse(itemID, rng, player, flags, customVar)
	if Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then
		return
	end
	local player_run_save = Mod:RunSave(player)

	player_run_save.ApocalypseStatUps = player_run_save.ApocalypseStatUps or {}

	for _, historyItem in ipairs(player:GetHistory():GetCollectiblesHistory()) do
		local passive = historyItem:GetItemID()
		local itemConfig = Mod.ItemConfig:GetCollectible(passive)
		if itemConfig.Type == ItemType.ITEM_PASSIVE
			or itemConfig.Type == ItemType.ITEM_FAMILIAR
		then
			player:RemoveCollectible(passive)
			local selectedStats = {}
			for _ = 1, 2 do
				local key = Mod:GetDifferentRandomKey(selectedStats, APOCALYPSE.StatTable, rng)
				selectedStats[key] = true
				player_run_save.ApocalypseStatUps[tostring(key)] = (player_run_save.ApocalypseStatUps[tostring(key)] or 0) + 1
			end
		end
	end

	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)

	Mod.SFXMan:Play(SoundEffect.SOUND_SATAN_GROW)
	Mod.Game:Darken(1, 120)
	Mod.Game:ShakeScreen(60)

	return {Discharge = true, Remove = true, ShowAnim = true}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, APOCALYPSE.UseApocalypse, APOCALYPSE.ID)

---@param player EntityPlayer
function APOCALYPSE:StatBuffs(player, flag)
	local player_run_save = Mod:RunSave(player)
	if not player_run_save.ApocalypseStatUps then return end

	for i, buffCount in pairs(player_run_save.ApocalypseStatUps) do
		local stat = APOCALYPSE.StatTable[tonumber(i)]

		if stat.Flag == flag then
			if flag == CacheFlag.CACHE_FIREDELAY then
				player[stat.Name] = Mod:TearsUp(player[stat.Name], buffCount * stat.Buff)
			else
				player[stat.Name] = player[stat.Name] + buffCount * stat.TempBuff
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, APOCALYPSE.StatBuffs)
