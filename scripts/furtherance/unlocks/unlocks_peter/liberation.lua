local Mod = Furtherance

local LIBERATION = {}

Furtherance.Item.LIBERATION = LIBERATION

LIBERATION.ID = Isaac.GetItemIdByName("Liberation")
LIBERATION.ACTIVATION_CHANCE = 1

local activatedLiberation = false

function LIBERATION:TryActivateLiberation()
	local chance = PlayerManager.GetNumCollectibles(LIBERATION.ID) * LIBERATION.ACTIVATION_CHANCE
	if chance > 0 and not activatedLiberation then
		local player = PlayerManager.FirstCollectibleOwner(LIBERATION.ID, false)
		if not player then return end
		local rng = player:GetCollectibleRNG(LIBERATION.ID)
		if rng:RandomFloat() <= LIBERATION.ACTIVATION_CHANCE then
			activatedLiberation = true
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

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, LIBERATION.TryActivateLiberation)

function LIBERATION:ResetLiberation()
	activatedLiberation = false
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LIBERATION.ResetLiberation)