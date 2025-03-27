local Mod = Furtherance

local GOLDEN_SACK = {}

Furtherance.Pickup.GOLDEN_SACK = GOLDEN_SACK

GOLDEN_SACK.ID = Isaac.GetEntitySubTypeByName("Golden Sack")

GOLDEN_SACK.REPLACE_CHANCE = 0.1
GOLDEN_SACK.DISAPPEAR_CHANCE = 0.2

function GOLDEN_SACK:SpawnGoldenSack(entityType, variant, subType, _, _, _, seed)
	if entityType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_GRAB_BAG
		and subType <= SackSubType.SACK_NORMAL
		--and Mod.PersistGameData:Unlocked(GOLDEN_SACK.ACHIEVEMENT)
	then
		local rng = RNG(seed)
		if rng:RandomFloat() <= GOLDEN_SACK.REPLACE_CHANCE then
			return { entityType, variant, GOLDEN_SACK.ID, seed }
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, GOLDEN_SACK.SpawnGoldenSack)

---@param pickup EntityPickup
---@param collider Entity
function GOLDEN_SACK:OnSackCollision(pickup, collider)
	local player = collider:ToPlayer()
	if player then
		local pickup_save = Mod:PickupSave(pickup, false)
		if not pickup_save.GoldenSackRNGSeed then
			pickup_save.GoldenSackRNGSeed = pickup.DropSeed
		end
		if RNG(pickup_save.GoldenSackRNGSeed):RandomFloat() > GOLDEN_SACK.DISAPPEAR_CHANCE then
			local room = Mod.Room()
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, GOLDEN_SACK.ID,
				room:FindFreePickupSpawnPosition(room:GetRandomPosition(0)), Vector.Zero, nil):ToPickup()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, GOLDEN_SACK.OnSackCollision, PickupVariant.PICKUP_GRAB_BAG)
