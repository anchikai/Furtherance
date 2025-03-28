local Mod = Furtherance

function Mod:UseBookOfAmbit(_Type, RNG, player)
	if GiantBookAPI then
		GiantBookAPI.playGiantBook("Appear", "ambit.png", Color(1, 1, 1, 1, 0, 0, 0), Color(1, 1, 1, 1, 0, 0, 0),
			Color(1, 1, 1, 1, 0, 0, 0), SoundEffect.SOUND_BOOK_PAGE_TURN_12, false)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseBookOfAmbit, CollectibleType.COLLECTIBLE_BOOK_OF_AMBIT)

function Mod:Ambit_CacheEval(player, flag)
	local tempEffects = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOOK_OF_AMBIT)
	if tempEffects > 0 then
		if flag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + tempEffects * 200
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + tempEffects * 1.5
		end
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.Ambit_CacheEval)

function Mod:Ambit_InitTear(tear)
	local player = Mod:GetPlayerFromTear(tear)
	if player then
		if player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOOK_OF_AMBIT) > 0 then
			tear:ChangeVariant(TearVariant.CUPID_BLUE)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, Mod.Ambit_InitTear)
