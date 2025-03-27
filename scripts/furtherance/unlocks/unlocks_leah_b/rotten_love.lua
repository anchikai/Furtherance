local Mod = Furtherance

local ROTTEN_LOVE = {}

Furtherance.Item.ROTTEN_LOVE = ROTTEN_LOVE

ROTTEN_LOVE.ID = Isaac.GetItemIdByName("Rotten Love")

---@param firstTime boolean
---@param player EntityPlayer
function ROTTEN_LOVE:SpawnHeartsOnFirstPickup(_, _, firstTime, _, _, player)
	if firstTime then
		local room = Mod.Room()
		local rng = player:GetCollectibleRNG(ROTTEN_LOVE.ID)
		for _ = 1, rng:RandomInt(2) + 2 do
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE,
				room:FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, player)
		end
		for _ = 1, rng:RandomInt(2) + 2 do
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN,
				room:FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, player)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ROTTEN_LOVE.SpawnHeartsOnFirstPickup, ROTTEN_LOVE.ID)
