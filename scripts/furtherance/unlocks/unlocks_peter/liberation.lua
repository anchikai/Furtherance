local Mod = Furtherance

local LIBERATION = {}

Furtherance.Item.LIBERATION = LIBERATION

LIBERATION.ID = Isaac.GetItemIdByName("Liberation")
LIBERATION.PROC_CHANCE = 0.05

function LIBERATION:TryActivateLiberation(ent)
	if not Mod:IsDeadEnemy(ent) or not PlayerManager.AnyoneHasCollectible(LIBERATION.ID) then return end
	local chance = PlayerManager.GetNumCollectibles(LIBERATION.ID) * LIBERATION.PROC_CHANCE
	local effects = Mod.Room():GetEffects()
	if chance > 0 and not effects:HasCollectibleEffect(LIBERATION.ID) then
		local player = PlayerManager.FirstCollectibleOwner(LIBERATION.ID, false)
		if not player then return end
		local rng = player:GetCollectibleRNG(LIBERATION.ID)
		if rng:RandomFloat() <= LIBERATION.PROC_CHANCE then
			effects:AddCollectibleEffect(LIBERATION.ID)
			player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, false, false, true, false, -1)
			Mod:ForEachPlayer(function(_player)
				if _player:HasCollectible(LIBERATION.ID) then
					_player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
					_player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BIBLE, true)
				end
			end)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, LIBERATION.TryActivateLiberation)
