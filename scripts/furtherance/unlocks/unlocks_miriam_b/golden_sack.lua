local Mod = Furtherance

local GOLDEN_SACK = {}

Furtherance.Pickup.GOLDEN_SACK = GOLDEN_SACK

GOLDEN_SACK.ID = Isaac.GetEntitySubTypeByName("Golden Sack")

GOLDEN_SACK.REPLACE_CHANCE = 0.1
GOLDEN_SACK.DISAPPEAR_CHANCE = 0.2

---@param pickup EntityPickup
---@param collider Entity
function GOLDEN_SACK:OnSackCollision(pickup, collider)
	local player = collider:ToPlayer()
	if player and pickup.SubType == GOLDEN_SACK.ID then
		local pickup_save = Mod:PickupSave(pickup, false)
		if not pickup_save.GoldenSackRNGSeed then
			pickup_save.GoldenSackRNGSeed = pickup.DropSeed
		end
		local rng = RNG(pickup_save.GoldenSackRNGSeed)
		if rng:RandomFloat() > GOLDEN_SACK.DISAPPEAR_CHANCE then
			pickup_save.GoldenSackRNGSeed = rng:Next()
			local room = Mod.Room()
			Mod.Spawn.Sack(GOLDEN_SACK.ID, room:FindFreePickupSpawnPosition(room:GetRandomPosition(0)), nil, nil, rng:Next())
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, GOLDEN_SACK.OnSackCollision, PickupVariant.PICKUP_GRAB_BAG)
