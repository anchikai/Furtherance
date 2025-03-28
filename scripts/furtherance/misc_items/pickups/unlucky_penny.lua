local Mod = Furtherance

Mod:SavePlayerData({
	UnluckyPennyStat = 0
})

function Mod:UnluckyPenny(pickup, collider)
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		local data = Mod:GetData(player)
		if collider:ToPlayer() and pickup.SubType == CoinSubType.COIN_UNLUCKYPENNY then
			SFXManager():Play(SoundEffect.SOUND_LUCKYPICKUP, 1, 2, false, 0.8)
			data.UnluckyPennyStat = data.UnluckyPennyStat + 1
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mod.UnluckyPenny, PickupVariant.PICKUP_COIN)

function Mod:Lucknt(player, flag)
	local data = Mod:GetData(player)
	if data.UnluckyPennyStat == nil then return end

	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + (data.UnluckyPennyStat / 2)
	end
	if flag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck - data.UnluckyPennyStat
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.Lucknt)
