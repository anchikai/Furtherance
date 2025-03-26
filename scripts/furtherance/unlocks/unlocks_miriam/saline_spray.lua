local Mod = Furtherance

local SALINE_SPRAY = {}

Furtherance.Trinket.SALINE_SPRAY = SALINE_SPRAY

SALINE_SPRAY.ID = Isaac.GetTrinketIdByName("Saline Spray")
SALINE_SPRAY.PROC_CHANCE = 0.05

--TODO: Will revisit for tear modifier implementation

---@param weaponEnt EntityTear | EntityKnife | EntityLaser | EntityBomb
function SALINE_SPRAY:TryApplyIceOnFire(weaponEnt)
	local player = weaponEnt.SpawnerEntity:ToPlayer()
	if player and player:HasTrinket(SALINE_SPRAY.ID) then
		local rng = player:GetTrinketRNG(SALINE_SPRAY.ID)

		local chance = SALINE_SPRAY.PROC_CHANCE
		if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
			chance = 1 - (1 - chance) ^ 2
		end

		if rng:RandomFloat() <= chance then
			weaponEnt.TearFlags = weaponEnt.TearFlags | TearFlags.TEAR_ICE
			weaponEnt:ChangeVariant(TearVariant.ICE)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, SALINE_SPRAY.TryApplyIceOnFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, SALINE_SPRAY.TryApplyIceOnFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, SALINE_SPRAY.TryApplyIceOnFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, SALINE_SPRAY.TryApplyIceOnFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_KNIFE, SALINE_SPRAY.TryApplyIceOnFire)
