local Mod = Furtherance
local game = Game()

function Mod:WormEffect(EntityTear)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		if player:HasTrinket(TrinketType.TRINKET_SLICK_WORM, false) then

		end
		player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
		player:EvaluateItems()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.WormEffect)

function Mod:Slick_CacheEval(player, flag)
	if player:HasTrinket(TrinketType.TRINKET_SLICK_WORM, false) then
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_BOUNCE
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.Slick_CacheEval)
