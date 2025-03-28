local Mod = Furtherance
local game = Game()

Mod:SavePlayerData({
	ShiftDamageBonus = 0
})

function Mod:UseShift(_, _, player)
	Mod:GetData(player).ShiftDamageBonus = 15
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseShift, CollectibleType.COLLECTIBLE_SHIFT_KEY)

function Mod:ShiftUpdate(player)
	local data = Mod:GetData(player)
	if data.ShiftDamageBonus == nil then
		data.ShiftDamageBonus = 0
		return
	end
	if data.ShiftDamageBonus <= 0 then return end

	-- every 0.5 seconds
	if game:GetFrameCount() % 15 == 0 then
		data.ShiftDamageBonus = math.max(data.ShiftDamageBonus - 0.125, 0)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.ShiftUpdate)

function Mod:ShiftBuffs(player, flag)
	local data = Mod:GetData(player)
	if data.ShiftDamageBonus == nil or data.ShiftDamageBonus <= 0 then return end

	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + data.ShiftDamageBonus
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.ShiftBuffs)
