local Mod = Furtherance

local LEAHS_LOCK = {}

Furtherance.Trinket.LEAHS_LOCK = LEAHS_LOCK

LEAHS_LOCK.ID = Isaac.GetTrinketIdByName("Leah's Lock")

--TODO: Will revisit for tear modifier implementation

--[[ ---@param ent EntityTear | EntityKnife | EntityLaser | EntityBomb
function LEAHS_LOCK:FireLLWeapon(ent)
	local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
	if not player or not player:HasTrinket(LEAHS_LOCK.ID) then return end

	local rng = player:GetTrinketRNG(LEAHS_LOCK.ID)
	local chance = 0.25 + math.min(player.Luck * 0.025, 0.25)
	if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
		chance = 1 - (1 - chance) ^ 2
	end

	local choice = rng:RandomFloat()
	if choice < chance / 2 then
		ent:AddTearFlags(TearFlags.TEAR_CHARM)
		ent:SetColor(Color(1, 0, 1, 1, 0.196, 0, 0), -1, 1, false, true)
	elseif choice < chance then
		ent:AddTearFlags(TearFlags.TEAR_FEAR)
		ent:SetColor(Color(1, 1, 0.455, 1, 0.169, 0.145, 0), -1, 1, false, true)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, LEAHS_LOCK.FireLLWeapon)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, LEAHS_LOCK.FireLLWeapon)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, LEAHS_LOCK.FireLLWeapon)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, LEAHS_LOCK.FireLLWeapon)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_KNIFE, LEAHS_LOCK.FireLLWeapon) ]]